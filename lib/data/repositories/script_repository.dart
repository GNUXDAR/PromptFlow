import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../domain/entities/script.dart';
import '../parsing/script_parser.dart';

/// Resumen ligero para listados (y para `welcome.scripts` en el protocolo).
final class ScriptSummary {
  const ScriptSummary({required this.id, required this.title, required this.path, required this.modified});
  final String id;
  final String title;
  final String path;
  final DateTime modified;

  Map<String, Object?> toJson() => {'id': id, 'title': title};
}

/// Persistencia en disco local (sin nube). Los guiones son ficheros
/// `.md`/`.txt` normales: se pueden editar también fuera de la app.
class ScriptRepository {
  ScriptRepository({Directory? root}) : _root = root; // ignore: prefer_initializing_formals

  Directory? _root;

  Future<Directory> get root async {
    if (_root != null) return _root!;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}${Platform.pathSeparator}PromptFlow');
    await dir.create(recursive: true);
    return _root = dir;
  }

  static ScriptFormat formatFor(String path) =>
      path.toLowerCase().endsWith('.txt') ? ScriptFormat.plainText : ScriptFormat.markdown;

  static String idFor(String path) => path.split(Platform.pathSeparator).last;

  Future<List<ScriptSummary>> list() async {
    final dir = await root;
    final out = <ScriptSummary>[];
    await for (final e in dir.list()) {
      if (e is! File) continue;
      final lower = e.path.toLowerCase();
      if (!lower.endsWith('.md') && !lower.endsWith('.txt')) continue;
      final head = await e.openRead(0, 512).transform(const SystemEncoding().decoder).join();
      final title = RegExp(r'^#\s+(.+)$', multiLine: true).firstMatch(head)?.group(1)?.trim();
      out.add(ScriptSummary(
        id: idFor(e.path),
        title: title ?? idFor(e.path),
        path: e.path,
        modified: await e.lastModified(),
      ));
    }
    out.sort((a, b) => b.modified.compareTo(a.modified));
    return out;
  }

  Future<Script> load(String path) async {
    final text = await File(path).readAsString();
    return ScriptParser.parse(text, id: idFor(path), format: formatFor(path));
  }

  Future<Script?> loadById(String id) async {
    final f = File('${(await root).path}${Platform.pathSeparator}$id');
    return await f.exists() ? load(f.path) : null;
  }

  /// Guarda dentro del directorio de la app. Devuelve la ruta final.
  Future<String> save(String fileName, String content) async {
    final safe = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final name = safe.contains('.') ? safe : '$safe.md';
    final f = File('${(await root).path}${Platform.pathSeparator}$name');
    await f.writeAsString(content, flush: true);
    return f.path;
  }

  Future<void> saveTo(String path, String content) => File(path).writeAsString(content, flush: true);
}
