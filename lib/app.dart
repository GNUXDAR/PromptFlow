import 'package:flutter/material.dart';

import 'data/repositories/script_repository.dart';
import 'domain/entities/prompter_settings.dart';
import 'presentation/screens/home_screen.dart';

class PromptFlowApp extends StatelessWidget {
  const PromptFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: PrompterPalette.yellow,
      brightness: Brightness.dark,
    ).copyWith(surface: const Color(0xFF0B0B0B), primary: PrompterPalette.yellow, onPrimary: Colors.black);

    return MaterialApp(
      title: 'PromptFlow',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorScheme: scheme,
        scaffoldBackgroundColor: PrompterPalette.background,
        useMaterial3: true,
        visualDensity: VisualDensity.standard,
      ),
      home: HomeScreen(repository: ScriptRepository()),
    );
  }
}
