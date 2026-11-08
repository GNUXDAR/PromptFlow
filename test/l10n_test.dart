import 'package:flutter_test/flutter_test.dart';
import 'package:promptflow/data/parsing/script_parser.dart';
import 'package:promptflow/domain/entities/script.dart';
import 'package:promptflow/l10n/app_localizations.dart';

/// Valida cada traducción: carga, guion de ejemplo con las etiquetas intactas,
/// nombre de archivo seguro y mensajes con placeholders y plurales.
void main() {
  const expectedLanguages = {'en', 'es', 'pt', 'fr', 'de', 'it', 'ru', 'zh', 'ja', 'ko', 'hi', 'ar'};

  test('están todos los idiomas previstos', () {
    final codes = AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();
    expect(codes, containsAll(expectedLanguages));
  });

  for (final locale in AppLocalizations.supportedLocales) {
    group(locale.languageCode, () {
      late AppLocalizations l;
      setUpAll(() async => l = await AppLocalizations.delegate.load(locale));

      test('guion de ejemplo: marcado y etiquetas intactos', () {
        final sample = l.homeSampleScript;
        for (final tag in ['[CAM 1]', '[CAM 2]', '[CUE Demo]', '[PAUSE 2s]', '[PAUSE 1.5s]', '[PAUSE]']) {
          expect(sample, contains(tag), reason: 'falta $tag');
        }
        final script = ScriptParser.parse(sample, id: 'sample');
        expect(script.blocks.where((b) => b.kind == BlockKind.heading), hasLength(4), reason: '# + 3 ##');
        expect(script.scheduledPauses, const Duration(milliseconds: 3500));
        expect(script.sections.any((s) => s.id.startsWith('cue-demo')), isTrue);
      });

      test('nombre del archivo de ejemplo seguro', () {
        expect(l.homeSampleFileName, matches(RegExp(r'^[A-Za-z0-9-]+\.md$')));
      });

      test('placeholders y plurales', () {
        expect(l.editorStats(120, 3), allOf(contains('120'), contains('3')));
        expect(l.voiceDownload(38), contains('38'));
        for (final n in [0, 1, 2, 3, 5, 11, 21, 100]) {
          final s = l.prompterServerInfo('192.168.1.20', 47820, '4821', n);
          expect(s, allOf(contains('192.168.1.20'), contains('47820'), contains('4821')));
        }
        expect(l.editorCueSnippet, startsWith('[CUE '));
        expect(l.aboutVersion('1.2.3'), contains('1.2.3'));
        expect(l.voiceDownloadPrompt('Español', 38), allOf(contains('Español'), contains('38')));
        expect(l.aboutOpenFailed('https://x.y'), contains('https://x.y'));
        expect(l.editorSection, startsWith('## '));
      });
    });
  }
}
