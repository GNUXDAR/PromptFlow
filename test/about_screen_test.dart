import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promptflow/core/app_info.dart';
import 'package:promptflow/l10n/app_localizations.dart';
import 'package:promptflow/presentation/screens/about_screen.dart';

Widget _app(Locale locale) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AboutScreen(),
    );

void main() {
  for (final locale in const [Locale('en'), Locale('es'), Locale('ar')]) {
    testWidgets('Acerca de (${locale.languageCode}): autor, versión y redes', (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_app(locale));
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(locale);
      expect(find.text(l10n.aboutTitle), findsOneWidget);
      expect(find.text(AppInfo.author), findsOneWidget);
      expect(find.text(l10n.aboutVersion(AppInfo.version)), findsOneWidget);
      for (final s in AppInfo.socials) {
        expect(find.text(s.network.label), findsOneWidget, reason: s.network.label);
      }
      expect(tester.takeException(), isNull, reason: 'sin desbordes de layout');
    });
  }
}
