#ifndef RUNNER_VOSK_STT_PLUGIN_H_
#define RUNNER_VOSK_STT_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

// Reconocimiento de voz local (Vosk) para PromptFlow en Linux.
//
// Canales (contrato en docs/ARCHITECTURE.md §5):
//   MethodChannel "promptflow/stt"
//     isAvailable {modelPath}          -> bool
//     start {modelPath, grammar?}      -> null   (responde cuando el micro está abierto)
//     stop                             -> null
//   EventChannel  "promptflow/stt/events"
//     {"raw": "<json de Vosk>", "final": bool}
//
// libvosk.so y libpulse-simple.so.0 se cargan con dlopen: la app compila y
// arranca sin ellas (isAvailable devuelve false).
void vosk_stt_plugin_register_with_registrar(FlPluginRegistrar* registrar);

#endif  // RUNNER_VOSK_STT_PLUGIN_H_
