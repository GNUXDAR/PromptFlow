#include "vosk_stt_plugin.h"

#include <dlfcn.h>
#include <limits.h>
#include <unistd.h>

#include <atomic>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <fstream>
#include <memory>
#include <mutex>
#include <string>
#include <thread>
#include <vector>

namespace {

constexpr float kSampleRate = 16000.0f;
// 100 ms de audio por bloque (16 kHz · 16 bit · mono): equilibrio entre
// latencia de los parciales y coste de CPU.
constexpr size_t kChunkBytes = 3200;

// ───────────────────── API C de Vosk (resuelta en runtime) ─────────────────────

struct VoskModel;
struct VoskRecognizer;

struct VoskApi {
  void* handle = nullptr;
  VoskModel* (*model_new)(const char*) = nullptr;
  void (*model_free)(VoskModel*) = nullptr;
  VoskRecognizer* (*recognizer_new)(VoskModel*, float) = nullptr;
  VoskRecognizer* (*recognizer_new_grm)(VoskModel*, float, const char*) = nullptr;
  int (*accept_waveform)(VoskRecognizer*, const char*, int) = nullptr;
  const char* (*result)(VoskRecognizer*) = nullptr;
  const char* (*partial_result)(VoskRecognizer*) = nullptr;
  const char* (*final_result)(VoskRecognizer*) = nullptr;
  void (*recognizer_free)(VoskRecognizer*) = nullptr;
  void (*set_log_level)(int) = nullptr;
};

// ───────────── PulseAudio "simple" (también sirve en PipeWire vía pipewire-pulse) ─────────────
// Tipos mínimos con el mismo ABI que <pulse/simple.h>, para no exigir libpulse-dev.

struct pa_simple;
struct PaSampleSpec {
  int format;  // pa_sample_format_t
  uint32_t rate;
  uint8_t channels;
};
struct PaBufferAttr {
  uint32_t maxlength, tlength, prebuf, minreq, fragsize;
};
constexpr int kPaSampleS16LE = 3;
constexpr int kPaStreamRecord = 2;

struct PulseApi {
  void* handle = nullptr;
  pa_simple* (*simple_new)(const char*, const char*, int, const char*, const char*,
                           const PaSampleSpec*, const void*, const PaBufferAttr*, int*) = nullptr;
  int (*simple_read)(pa_simple*, void*, size_t, int*) = nullptr;
  void (*simple_free)(pa_simple*) = nullptr;
  const char* (*strerror)(int) = nullptr;
};

template <typename T>
bool Resolve(void* handle, const char* name, T* out) {
  *out = reinterpret_cast<T>(dlsym(handle, name));
  return *out != nullptr;
}

std::string ExecutableDir() {
  char buf[PATH_MAX];
  ssize_t n = readlink("/proc/self/exe", buf, sizeof(buf) - 1);
  if (n <= 0) return ".";
  buf[n] = '\0';
  std::string path(buf);
  return path.substr(0, path.find_last_of('/'));
}

// ───────────────────── Fuentes de audio ─────────────────────

class AudioSource {
 public:
  virtual ~AudioSource() = default;
  // Lee hasta kChunkBytes. Devuelve bytes leídos; 0 = fin; -1 = error.
  virtual int Read(char* buf, std::string* error) = 0;
};

class MicSource : public AudioSource {
 public:
  MicSource(const PulseApi& api, pa_simple* stream) : api_(api), stream_(stream) {}
  ~MicSource() override { api_.simple_free(stream_); }

  int Read(char* buf, std::string* error) override {
    int err = 0;
    if (api_.simple_read(stream_, buf, kChunkBytes, &err) < 0) {
      *error = std::string("Error leyendo el micrófono: ") + api_.strerror(err);
      return -1;
    }
    return static_cast<int>(kChunkBytes);
  }

 private:
  const PulseApi& api_;
  pa_simple* stream_;
};

// WAV PCM 16 kHz mono a ritmo de tiempo real. Se activa con la variable de
// entorno PROMPTFLOW_STT_WAV para pruebas de integración sin micrófono.
class WavSource : public AudioSource {
 public:
  explicit WavSource(const std::string& path) : file_(path, std::ios::binary) {}

  bool Open(std::string* error) {
    if (!file_) {
      *error = "No se pudo abrir el WAV";
      return false;
    }
    char riff[12];
    file_.read(riff, 12);
    if (std::memcmp(riff, "RIFF", 4) != 0 || std::memcmp(riff + 8, "WAVE", 4) != 0) {
      *error = "El fichero no es WAV";
      return false;
    }
    // Busca el chunk "data" (puede haber "fmt ", "LIST", …).
    char id[4];
    uint32_t size = 0;
    while (file_.read(id, 4) && file_.read(reinterpret_cast<char*>(&size), 4)) {
      if (std::memcmp(id, "data", 4) == 0) return true;
      file_.seekg(size + (size & 1), std::ios::cur);
    }
    *error = "WAV sin chunk de datos";
    return false;
  }

  int Read(char* buf, std::string*) override {
    std::this_thread::sleep_until(next_);
    next_ = std::chrono::steady_clock::now() + std::chrono::milliseconds(100);
    file_.read(buf, kChunkBytes);
    return static_cast<int>(file_.gcount());
  }

 private:
  std::ifstream file_;
  std::chrono::steady_clock::time_point next_ = std::chrono::steady_clock::now();
};

// ───────────────────── Plugin ─────────────────────

struct Plugin {
  FlMethodChannel* methods = nullptr;
  FlEventChannel* events = nullptr;
  std::atomic<bool> listening{false};

  VoskApi vosk;
  PulseApi pulse;
  bool vosk_tried = false;
  bool pulse_tried = false;

  std::thread worker;
  std::atomic<bool> running{false};

  // El modelo se conserva entre start/stop (cargarlo cuesta ~1 s).
  std::mutex model_mutex;
  VoskModel* model = nullptr;
  std::string model_path;
};

Plugin* g_plugin = nullptr;

bool LoadVosk(Plugin* p) {
  if (p->vosk_tried) return p->vosk.handle != nullptr;
  p->vosk_tried = true;
  // 1) La copia empaquetada en bundle/lib, 2) la del sistema (LD_LIBRARY_PATH).
  const std::string bundled = ExecutableDir() + "/lib/libvosk.so";
  void* h = dlopen(bundled.c_str(), RTLD_NOW | RTLD_LOCAL);
  if (!h) h = dlopen("libvosk.so", RTLD_NOW | RTLD_LOCAL);
  if (!h) return false;
  VoskApi& v = p->vosk;
  bool ok = Resolve(h, "vosk_model_new", &v.model_new) && Resolve(h, "vosk_model_free", &v.model_free) &&
            Resolve(h, "vosk_recognizer_new", &v.recognizer_new) &&
            Resolve(h, "vosk_recognizer_new_grm", &v.recognizer_new_grm) &&
            Resolve(h, "vosk_recognizer_accept_waveform", &v.accept_waveform) &&
            Resolve(h, "vosk_recognizer_result", &v.result) &&
            Resolve(h, "vosk_recognizer_partial_result", &v.partial_result) &&
            Resolve(h, "vosk_recognizer_final_result", &v.final_result) &&
            Resolve(h, "vosk_recognizer_free", &v.recognizer_free) &&
            Resolve(h, "vosk_set_log_level", &v.set_log_level);
  if (!ok) {
    dlclose(h);
    return false;
  }
  v.handle = h;
  v.set_log_level(-1);  // silencia los logs de Kaldi
  return true;
}

bool LoadPulse(Plugin* p) {
  if (p->pulse_tried) return p->pulse.handle != nullptr;
  p->pulse_tried = true;
  void* h = dlopen("libpulse-simple.so.0", RTLD_NOW | RTLD_LOCAL);
  if (!h) return false;
  PulseApi& a = p->pulse;
  // pa_strerror vive en libpulse.so.0; dlsym con el handle busca también
  // en sus dependencias.
  bool ok = Resolve(h, "pa_simple_new", &a.simple_new) && Resolve(h, "pa_simple_read", &a.simple_read) &&
            Resolve(h, "pa_simple_free", &a.simple_free) && Resolve(h, "pa_strerror", &a.strerror);
  if (!ok) {
    dlclose(h);
    return false;
  }
  a.handle = h;
  return true;
}

const char* WavOverride() {
  const char* wav = g_getenv("PROMPTFLOW_STT_WAV");
  return (wav != nullptr && *wav != '\0') ? wav : nullptr;
}

// Formato actual (am/, conf/) o antiguo (todo en la raíz, p. ej. small-pt-0.3).
bool ModelLooksValid(const std::string& path) {
  auto exists = [&](const char* rel) { return g_file_test((path + rel).c_str(), G_FILE_TEST_IS_REGULAR); };
  return (exists("/am/final.mdl") || exists("/final.mdl")) && (exists("/conf/mfcc.conf") || exists("/mfcc.conf"));
}

// ─── Puente hilo de trabajo → hilo principal (GTK/Flutter no son thread-safe) ───

struct Event {
  std::string raw;
  bool is_final = false;
  std::string error;  // si no está vacío, se envía como error del stream
};

gboolean EmitOnMain(gpointer data) {
  std::unique_ptr<Event> e(static_cast<Event*>(data));
  Plugin* p = g_plugin;
  if (p == nullptr || !p->listening) return G_SOURCE_REMOVE;
  if (!e->error.empty()) {
    fl_event_channel_send_error(p->events, "stt_error", e->error.c_str(), nullptr, nullptr, nullptr);
    return G_SOURCE_REMOVE;
  }
  g_autoptr(FlValue) map = fl_value_new_map();
  fl_value_set_string_take(map, "raw", fl_value_new_string(e->raw.c_str()));
  fl_value_set_string_take(map, "final", fl_value_new_bool(e->is_final));
  fl_event_channel_send(p->events, map, nullptr, nullptr);
  return G_SOURCE_REMOVE;
}

void Post(Event* e) { g_idle_add(EmitOnMain, e); }

struct Reply {
  FlMethodCall* call;  // con referencia
  std::string error;
};

gboolean ReplyOnMain(gpointer data) {
  std::unique_ptr<Reply> r(static_cast<Reply*>(data));
  if (r->error.empty()) {
    fl_method_call_respond_success(r->call, nullptr, nullptr);
  } else {
    fl_method_call_respond_error(r->call, "stt_start_failed", r->error.c_str(), nullptr, nullptr);
  }
  g_object_unref(r->call);
  return G_SOURCE_REMOVE;
}

// ───────────────────── Hilo de reconocimiento ─────────────────────

void RecognitionLoop(Plugin* p, std::string model_path, std::string grammar, FlMethodCall* call) {
  auto fail_start = [&](const std::string& msg) {
    p->running = false;
    g_idle_add(ReplyOnMain, new Reply{call, msg});
  };

  VoskModel* model = nullptr;
  {
    std::lock_guard<std::mutex> lock(p->model_mutex);
    if (p->model == nullptr || p->model_path != model_path) {
      if (p->model != nullptr) p->vosk.model_free(p->model);
      p->model = p->vosk.model_new(model_path.c_str());
      p->model_path = p->model ? model_path : "";
    }
    model = p->model;
  }
  if (model == nullptr) return fail_start("No se pudo cargar el modelo de Vosk en " + model_path);

  // Con gramática (lista JSON de palabras del guion + "[unk]") el modelo
  // pequeño solo elige entre palabras del guion: mucha más precisión.
  VoskRecognizer* rec = grammar.empty() ? p->vosk.recognizer_new(model, kSampleRate)
                                        : p->vosk.recognizer_new_grm(model, kSampleRate, grammar.c_str());
  if (rec == nullptr) return fail_start("No se pudo crear el reconocedor");

  std::unique_ptr<AudioSource> source;
  std::string error;
  if (const char* wav = WavOverride()) {
    auto w = std::make_unique<WavSource>(wav);
    if (w->Open(&error)) source = std::move(w);
  } else {
    PaSampleSpec spec{kPaSampleS16LE, static_cast<uint32_t>(kSampleRate), 1};
    // fragsize pequeño = el servidor de audio entrega cada 100 ms (baja latencia).
    PaBufferAttr attr{UINT32_MAX, UINT32_MAX, UINT32_MAX, UINT32_MAX, static_cast<uint32_t>(kChunkBytes)};
    int err = 0;
    pa_simple* s = p->pulse.simple_new(nullptr, "PromptFlow", kPaStreamRecord, nullptr, "Seguimiento por voz",
                                       &spec, nullptr, &attr, &err);
    if (s != nullptr) {
      source = std::make_unique<MicSource>(p->pulse, s);
    } else {
      error = std::string("No se pudo abrir el micrófono: ") + p->pulse.strerror(err);
    }
  }
  if (!source) {
    p->vosk.recognizer_free(rec);
    return fail_start(error);
  }

  g_idle_add(ReplyOnMain, new Reply{call, ""});  // start() resuelve aquí

  std::vector<char> buf(kChunkBytes);
  std::string last_partial;
  while (p->running) {
    int n = source->Read(buf.data(), &error);
    if (n < 0) {
      Post(new Event{"", false, error});
      break;
    }
    if (n == 0) break;  // fin del WAV
    if (p->vosk.accept_waveform(rec, buf.data(), n)) {
      // Vosk detectó un silencio (endpoint): frase cerrada.
      Post(new Event{p->vosk.result(rec), true, ""});
      last_partial.clear();
    } else {
      std::string partial = p->vosk.partial_result(rec);
      if (partial != last_partial) {  // solo cambios: menos tráfico al hilo UI
        last_partial = partial;
        Post(new Event{partial, false, ""});
      }
    }
  }
  Post(new Event{p->vosk.final_result(rec), true, ""});
  p->vosk.recognizer_free(rec);
  p->running = false;
}

void StopWorker(Plugin* p) {
  p->running = false;
  // El hilo sale en ≤100 ms (lo que tarda en volver pa_simple_read).
  if (p->worker.joinable()) p->worker.join();
}

std::string StringArg(FlValue* args, const char* key) {
  if (args == nullptr || fl_value_get_type(args) != FL_VALUE_TYPE_MAP) return "";
  FlValue* v = fl_value_lookup_string(args, key);
  if (v == nullptr || fl_value_get_type(v) != FL_VALUE_TYPE_STRING) return "";
  return fl_value_get_string(v);
}

void HandleMethodCall(FlMethodChannel*, FlMethodCall* call, gpointer user_data) {
  Plugin* p = static_cast<Plugin*>(user_data);
  const gchar* method = fl_method_call_get_name(call);
  FlValue* args = fl_method_call_get_args(call);

  if (g_strcmp0(method, "isAvailable") == 0) {
    const std::string model = StringArg(args, "modelPath");
    const bool audio_ok = WavOverride() != nullptr || LoadPulse(p);
    const bool ok = LoadVosk(p) && audio_ok && ModelLooksValid(model);
    g_autoptr(FlValue) result = fl_value_new_bool(ok);
    fl_method_call_respond_success(call, result, nullptr);
    return;
  }

  if (g_strcmp0(method, "start") == 0) {
    const std::string model = StringArg(args, "modelPath");
    if (!LoadVosk(p)) {
      fl_method_call_respond_error(call, "stt_unavailable", "libvosk.so no encontrada", nullptr, nullptr);
      return;
    }
    if (WavOverride() == nullptr && !LoadPulse(p)) {
      fl_method_call_respond_error(call, "stt_unavailable", "libpulse-simple.so.0 no encontrada", nullptr,
                                   nullptr);
      return;
    }
    if (!ModelLooksValid(model)) {
      fl_method_call_respond_error(call, "stt_no_model", ("Modelo no encontrado en " + model).c_str(), nullptr,
                                   nullptr);
      return;
    }
    StopWorker(p);
    p->running = true;
    // La respuesta llega desde el hilo cuando el modelo y el micro están listos,
    // así la carga del modelo no congela la interfaz.
    p->worker = std::thread(RecognitionLoop, p, model, StringArg(args, "grammar"),
                            FL_METHOD_CALL(g_object_ref(call)));
    return;
  }

  if (g_strcmp0(method, "stop") == 0) {
    StopWorker(p);
    fl_method_call_respond_success(call, nullptr, nullptr);
    return;
  }

  fl_method_call_respond_not_implemented(call, nullptr);
}

FlMethodErrorResponse* OnListen(FlEventChannel*, FlValue*, gpointer user_data) {
  static_cast<Plugin*>(user_data)->listening = true;
  return nullptr;
}

FlMethodErrorResponse* OnCancel(FlEventChannel*, FlValue*, gpointer user_data) {
  static_cast<Plugin*>(user_data)->listening = false;
  return nullptr;
}

}  // namespace

void vosk_stt_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  if (g_plugin != nullptr) return;
  // Vive lo mismo que el proceso; nunca se destruye (evita que el destructor
  // de std::thread aborte si el hilo sigue activo al cerrar la app).
  g_plugin = new Plugin();

  FlBinaryMessenger* messenger = fl_plugin_registrar_get_messenger(registrar);
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();

  g_plugin->methods = fl_method_channel_new(messenger, "promptflow/stt", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(g_plugin->methods, HandleMethodCall, g_plugin, nullptr);

  g_plugin->events = fl_event_channel_new(messenger, "promptflow/stt/events", FL_METHOD_CODEC(codec));
  fl_event_channel_set_stream_handlers(g_plugin->events, OnListen, OnCancel, g_plugin, nullptr);
}
