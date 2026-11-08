import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:promptflow/voice/voice_models.dart';

void main() {
  test('catálogo: códigos únicos y una carpeta por idioma', () {
    final codes = VoiceModels.all.map((m) => m.code).toSet();
    expect(codes, hasLength(VoiceModels.all.length));
    expect(VoiceModels.byCode('xx').code, 'es', reason: 'idioma desconocido → español');
    expect(VoiceModels.dirFor(Directory('/r'), 'fr'), '/r/models/vosk-fr');
  });

  // Descarga real (~31 MB). Solo con PROMPTFLOW_TEST_DOWNLOAD=1.
  final download = Platform.environment['PROMPTFLOW_TEST_DOWNLOAD'] == '1';

  test('instala un modelo real y deja la carpeta lista', () async {
    final root = await Directory.systemTemp.createTemp('pf-models-');
    addTearDown(() => root.delete(recursive: true));
    final dir = VoiceModels.dirFor(root, 'pt');
    final seen = <double?>[];
    await VoiceModelInstaller(VoiceModels.byCode('pt'), dir).install(onProgress: seen.add);
    expect(await VoiceModels.isInstalled(dir), isTrue);
    expect(seen.whereType<double>().last, closeTo(1, 0.001));
    expect(seen, contains(null), reason: 'fase de extracción notificada');
    expect(await Directory('${root.path}/models/.download-pt').exists(), isFalse, reason: 'limpia temporales');
  }, skip: !download, timeout: const Timeout(Duration(minutes: 5)));

  test('cancelar a mitad no deja restos', () async {
    final root = await Directory.systemTemp.createTemp('pf-models-');
    addTearDown(() => root.delete(recursive: true));
    final dir = VoiceModels.dirFor(root, 'pt');
    late VoiceModelInstaller installer;
    installer = VoiceModelInstaller(VoiceModels.byCode('pt'), dir);
    final future = installer.install(onProgress: (p) {
      if (p != null && p > 0.1) installer.cancel();
    });
    await expectLater(future, throwsA(isA<VoiceModelCancelled>()));
    expect(await Directory(dir).exists(), isFalse);
    expect(await Directory('${root.path}/models/.download-pt').exists(), isFalse);
  }, skip: !download, timeout: const Timeout(Duration(minutes: 2)));
}
