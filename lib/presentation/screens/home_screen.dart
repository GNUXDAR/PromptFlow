import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/script_repository.dart';
import '../l10n.dart';
import 'about_screen.dart';
import 'editor_screen.dart';
import 'prompter_screen.dart';
import 'remote_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});
  final ScriptRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<ScriptSummary>>? _scripts;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scripts ??= _load();
  }

  Future<List<ScriptSummary>> _load() async {
    // El guion de ejemplo se crea en el idioma del sistema.
    final l10n = context.l10n;
    var list = await widget.repository.list();
    if (list.isEmpty) {
      await widget.repository.save(l10n.homeSampleFileName, l10n.homeSampleScript);
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
        title: Text(context.l10n.appTitle),
        actions: [
          IconButton(tooltip: context.l10n.homeImport, onPressed: _import, icon: const Icon(Icons.file_open)),
          IconButton(
            tooltip: context.l10n.aboutTitle,
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AboutScreen())),
            icon: const Icon(Icons.info_outline),
          ),
          IconButton(
            tooltip: context.l10n.homeRemote,
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => const RemoteScreen())),
            icon: const Icon(Icons.settings_remote),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.homeNewScript),
      ),
      body: FutureBuilder<List<ScriptSummary>>(
        future: _scripts,
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text(context.l10n.commonError('${snap.error}')));
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
                  tooltip: context.l10n.homeEditScript(s.title),
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
