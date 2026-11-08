import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';

/// Modelo pequeño de Vosk para un idioma (aptos para móvil: 31–83 MB).
final class VoiceModel {
  const VoiceModel(this.code, this.name, this.archive, this.sizeMb);

  /// Código de idioma; también da nombre a la carpeta: `models/vosk-<code>`.
  final String code;

  /// Nombre del idioma en su propia lengua (no depende de la traducción de la UI).
  final String name;
  final String archive;
  final int sizeMb;

  Uri get url => Uri.parse('https://alphacephei.com/vosk/models/$archive.zip');
}

/// Catálogo verificado de alphacephei.com/vosk/models. El árabe no se incluye:
/// sus modelos pesan 158–318 MB, demasiado para descargarlos en un teléfono.
abstract final class VoiceModels {
  static const all = [
    VoiceModel('es', 'Español', 'vosk-model-small-es-0.42', 38),
    VoiceModel('en', 'English', 'vosk-model-small-en-us-0.15', 39),
    VoiceModel('pt', 'Português', 'vosk-model-small-pt-0.3', 31),
    VoiceModel('fr', 'Français', 'vosk-model-small-fr-0.22', 40),
    VoiceModel('de', 'Deutsch', 'vosk-model-small-de-0.15', 44),
    VoiceModel('it', 'Italiano', 'vosk-model-small-it-0.22', 47),
    VoiceModel('ru', 'Русский', 'vosk-model-small-ru-0.22', 44),
    VoiceModel('zh', '中文', 'vosk-model-small-cn-0.22', 42),
    VoiceModel('ja', '日本語', 'vosk-model-small-ja-0.22', 47),
    VoiceModel('ko', '한국어', 'vosk-model-small-ko-0.22', 83),
    VoiceModel('hi', 'हिन्दी', 'vosk-model-small-hi-0.22', 42),
  ];

  /// Idioma de voz por defecto para un idioma del sistema.
  static String defaultFor(String languageCode) =>
      all.any((m) => m.code == languageCode) ? languageCode : 'es';

  static VoiceModel byCode(String code) => all.firstWhere((m) => m.code == code, orElse: () => all.first);

  static String dirFor(Directory root, String code) => '${root.path}/models/vosk-$code';

  /// Admite los dos formatos de Vosk: el actual (`am/final.mdl`,
  /// `conf/mfcc.conf`) y el antiguo con todo en la raíz (p. ej. `small-pt-0.3`).
  static Future<bool> isInstalled(String modelDir) async =>
      (await File('$modelDir/am/final.mdl').exists() || await File('$modelDir/final.mdl').exists()) &&
      (await File('$modelDir/conf/mfcc.conf').exists() || await File('$modelDir/mfcc.conf').exists());
}

/// Descarga e instala un modelo. La extracción (~70 MB descomprimidos) se hace
/// en otro isolate para no congelar la interfaz.
class VoiceModelInstaller {
  VoiceModelInstaller(this.model, this.targetDir);

  final VoiceModel model;
  final String targetDir;
  bool _cancelled = false;
  HttpClient? _client;

  void cancel() {
    _cancelled = true;
    _client?.close(force: true);
  }

  /// [onProgress] recibe 0–1 durante la descarga y `null` mientras extrae.
  Future<void> install({required void Function(double? progress) onProgress}) async {
    final target = Directory(targetDir);
    final work = Directory('${target.parent.path}/.download-${model.code}');
    if (await work.exists()) await work.delete(recursive: true);
    await work.create(recursive: true);
    final zip = File('${work.path}/model.zip');

    try {
      _client = HttpClient()..userAgent = 'PromptFlow';
      final res = await (await _client!.getUrl(model.url)).close();
      if (res.statusCode != HttpStatus.ok) {
        throw HttpException('HTTP ${res.statusCode}', uri: model.url);
      }
      final total = res.contentLength;
      var received = 0;
      final sink = zip.openWrite();
      await for (final chunk in res) {
        if (_cancelled) break;
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress(received / total);
      }
      await sink.close();
      if (_cancelled) throw const VoiceModelCancelled();

      onProgress(null);
      final zipPath = zip.path, outPath = '${work.path}/out';
      await Isolate.run(() => extractFileToDisk(zipPath, outPath));

      // El zip contiene una carpeta raíz con el nombre del modelo.
      final extracted = Directory('$outPath/${model.archive}');
      if (!await VoiceModels.isInstalled(extracted.path)) {
        throw const FormatException('El archivo descargado no contiene un modelo de Vosk');
      }
      if (await target.exists()) await target.delete(recursive: true);
      await extracted.rename(target.path);
    } on HttpException {
      if (_cancelled) throw const VoiceModelCancelled();
      rethrow;
    } on SocketException {
      if (_cancelled) throw const VoiceModelCancelled();
      rethrow;
    } finally {
      _client?.close(force: true);
      if (await work.exists()) await work.delete(recursive: true);
    }
  }
}

final class VoiceModelCancelled implements Exception {
  const VoiceModelCancelled();
}
