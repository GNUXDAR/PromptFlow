package com.actecnology.promptflow

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.vosk.LibVosk
import org.vosk.LogLevel
import org.vosk.Model
import org.vosk.Recognizer
import org.vosk.android.RecognitionListener
import org.vosk.android.SpeechService
import java.io.File
import java.util.concurrent.Executors

/**
 * Reconocimiento de voz local (Vosk) para PromptFlow en Android.
 *
 * Mismo contrato que el plugin de Linux (docs/ARCHITECTURE.md §5):
 *   MethodChannel "promptflow/stt"
 *     isAvailable {modelPath}        -> Boolean
 *     start {modelPath, grammar?}    -> null cuando el micro ya está abierto
 *     stop                           -> null
 *   EventChannel  "promptflow/stt/events"
 *     {"raw": "<json de Vosk>", "final": Boolean}
 *
 * La captura (AudioRecord 16 kHz mono) y el reconocimiento los hace
 * [SpeechService] de vosk-android en su propio hilo; los callbacks llegan
 * al hilo principal, que es donde Flutter exige enviar los eventos.
 */
class VoskSttPlugin(
    private val activity: Activity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler, RecognitionListener {

    companion object {
        private const val SAMPLE_RATE = 16000f
        const val PERMISSION_REQUEST_CODE = 0x5717
    }

    private val methods = MethodChannel(messenger, "promptflow/stt")
    private val events = EventChannel(messenger, "promptflow/stt/events")
    private val main = Handler(Looper.getMainLooper())

    // Cargar el modelo cuesta ~1 s: se hace fuera del hilo principal y se
    // conserva entre start/stop mientras no cambie la ruta.
    private val loader = Executors.newSingleThreadExecutor()

    private var sink: EventChannel.EventSink? = null
    private var model: Model? = null
    private var modelPath: String? = null
    private var recognizer: Recognizer? = null
    private var service: SpeechService? = null

    /** start() en espera del permiso de micrófono. */
    private var pendingStart: Pair<MethodCall, MethodChannel.Result>? = null

    init {
        LibVosk.setLogLevel(LogLevel.WARNINGS)
        methods.setMethodCallHandler(this)
        events.setStreamHandler(this)
    }

    // ───────────────────────── MethodChannel ─────────────────────────

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isAvailable" -> result.success(modelLooksValid(call.argument<String>("modelPath")))
            "start" -> start(call, result)
            "stop" -> {
                stopListening()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun start(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("modelPath")
        if (!modelLooksValid(path)) {
            result.error("stt_no_model", "Model not found at $path", null)
            return
        }
        if (activity.checkSelfPermission(Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            pendingStart?.second?.error("stt_cancelled", "Superseded by another request", null)
            pendingStart = call to result
            activity.requestPermissions(arrayOf(Manifest.permission.RECORD_AUDIO), PERMISSION_REQUEST_CODE)
            return
        }
        stopListening()
        val grammar = call.argument<String>("grammar")
        loader.execute {
            try {
                val m = synchronized(this) {
                    if (model == null || modelPath != path) {
                        model?.close()
                        model = Model(path)
                        modelPath = path
                    }
                    model!!
                }
                // Con gramática (palabras del guion + "[unk]") el modelo pequeño
                // solo elige entre palabras del guion: más precisión.
                val rec = if (grammar.isNullOrEmpty()) Recognizer(m, SAMPLE_RATE)
                else Recognizer(m, SAMPLE_RATE, grammar)
                main.post {
                    try {
                        val svc = SpeechService(rec, SAMPLE_RATE)
                        recognizer = rec
                        service = svc
                        svc.startListening(this)
                        result.success(null)
                    } catch (e: Exception) {
                        rec.close()
                        result.error("stt_start_failed", "Could not open the microphone: ${e.message}", null)
                    }
                }
            } catch (e: Exception) {
                main.post { result.error("stt_start_failed", "Could not load the model: ${e.message}", null) }
            }
        }
    }

    private fun stopListening() {
        service?.let {
            it.stop()
            it.shutdown()
        }
        service = null
        recognizer?.close()
        recognizer = null
    }

    /** Lo llama MainActivity.onRequestPermissionsResult. */
    fun onPermissionResult(requestCode: Int, grantResults: IntArray): Boolean {
        if (requestCode != PERMISSION_REQUEST_CODE) return false
        val (call, result) = pendingStart ?: return true
        pendingStart = null
        if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
            start(call, result)
        } else {
            result.error("stt_permission", "Microphone permission denied", null)
        }
        return true
    }

    /** Formato actual (am/, conf/) o antiguo (todo en la raíz, p. ej. small-pt-0.3). */
    private fun modelLooksValid(path: String?): Boolean {
        if (path == null) return false
        fun has(rel: String) = File(path, rel).isFile
        return (has("am/final.mdl") || has("final.mdl")) && (has("conf/mfcc.conf") || has("mfcc.conf"))
    }

    // ───────────────────────── EventChannel ─────────────────────────

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    private fun emit(raw: String?, final: Boolean) {
        if (raw.isNullOrEmpty()) return
        main.post { sink?.success(mapOf("raw" to raw, "final" to final)) }
    }

    // ───────────────────────── RecognitionListener ─────────────────────────

    private var lastPartial: String? = null

    override fun onPartialResult(hypothesis: String?) {
        if (hypothesis == lastPartial) return // solo cambios: menos tráfico al hilo UI
        lastPartial = hypothesis
        emit(hypothesis, false)
    }

    override fun onResult(hypothesis: String?) {
        lastPartial = null
        emit(hypothesis, true)
    }

    override fun onFinalResult(hypothesis: String?) = emit(hypothesis, true)

    override fun onError(exception: Exception?) {
        main.post { sink?.error("stt_error", exception?.message ?: "Recognition error", null) }
    }

    override fun onTimeout() = Unit

    fun dispose() {
        stopListening()
        methods.setMethodCallHandler(null)
        events.setStreamHandler(null)
        loader.execute {
            synchronized(this) {
                model?.close()
                model = null
            }
        }
        loader.shutdown()
    }
}
