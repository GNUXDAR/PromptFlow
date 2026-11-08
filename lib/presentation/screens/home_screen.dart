import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/script_repository.dart';
import 'editor_screen.dart';
import 'prompter_screen.dart';
import 'remote_screen.dart';

const sampleScript = '''# Guion de ejemplo

## Apertura
[CAM 1] Hola y **bienvenidos** a PromptFlow. Este es un guion de ejemplo
que muestra las marcas disponibles. [PAUSE 2s]

Puedes poner palabras en **negrita** para enfatizar, o ==resaltarlas==
cuando sean importantes.

## Demostración
[CAM 2] [CUE Demo] Ahora cambiamos de cámara. Las pausas automáticas detienen
el texto unos segundos y continúan solas. [PAUSE 1.5s]

Una pausa sin duración detiene el texto hasta que pulses Play. [PAUSE]

## Cierre
[CAM 1] Gracias por ver. Controla el prompter desde tu teléfono con el
modo **Control remoto**, o con un pedal Bluetooth.
''';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});
  final ScriptRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<ScriptSummary>> _scripts = _load();

  Future<List<ScriptSummary>> _load() async {
    var list = await widget.repository.list();
    if (list.isEmpty) {
      await widget.repository.save('ejemplo.md', sampleScript);
      list = await widget.repository.list();
    }
    return list;
  }

  void _reload() => setState(() => _scripts = _load());

  Future<void> _open(String path) async {
    final script = await widget.repository.load(path);
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => PrompterScreen(repository: widget.repository, script: script),
    ));
    _reload();
  }

  Future<void> _edit({String? path}) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => EditorScreen(repository: widget.repository, path: path),
    ));
    _reload();
  }

  Future<void> _import() async {
    final files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['txt', 'md']);
    final src = files.isEmpty ? null : files.first.path;
    if (src == null) return;
    final text = await File(src).readAsString();
    final saved = await widget.repository.save(ScriptRepository.idFor(src), text);
    _reload();
    await _edit(path: saved);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PromptFlow'),
        actions: [
          IconButton(tooltip: 'Importar .txt / .md', onPressed: _import, icon: const Icon(Icons.file_open)),
          IconButton(
            tooltip: 'Control remoto',
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => const RemoteScreen())),
            icon: const Icon(Icons.settings_remote),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo guion'),
      ),
      body: FutureBuilder<List<ScriptSummary>>(
        future: _scripts,
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          final list = snap.data;
          if (list == null) return const Center(child: CircularProgressIndicator());
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final s = list[i];
              return ListTile(
                title: Text(s.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(s.id),
                onTap: () => _open(s.path),
                trailing: IconButton(
                  tooltip: 'Editar ${s.title}',
                  icon: const Icon(Icons.edit),
                  onPressed: () => _edit(path: s.path),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
