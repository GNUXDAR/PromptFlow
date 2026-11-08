import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/parsing/script_parser.dart';
import '../../data/repositories/script_repository.dart';
import '../../domain/entities/script.dart';
import '../../domain/services/wpm_estimator.dart';
import 'prompter_screen.dart';

/// Editor de guiones (Módulo B): texto plano / Markdown con etiquetas,
/// estadísticas en vivo y cálculo de WPM para una duración objetivo.
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key, required this.repository, this.path});
  final ScriptRepository repository;
  final String? path;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final _text = TextEditingController();
  final _name = TextEditingController(text: 'guion.md');
  String? _path;
  double _wpm = 140;
  Duration? _target;
  Script _parsed = ScriptParser.parse('', id: 'draft');
  Timer? _debounce;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _path = widget.path;
    if (_path != null) {
      _name.text = ScriptRepository.idFor(_path!);
      File(_path!).readAsString().then((t) {
        _text.text = t;
        _reparse();
        _dirty = false;
      });
    }
    _text.addListener(() {
      _dirty = true;
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 250), _reparse);
    });
  }

  void _reparse() {
    if (!mounted) return;
    setState(() {
      _parsed = ScriptParser.parse(_text.text,
          id: _name.text, format: ScriptRepository.formatFor(_name.text));
    });
  }

  void _insert(String snippet) {
    final sel = _text.selection;
    final start = sel.isValid ? sel.start : _text.text.length;
    final end = sel.isValid ? sel.end : _text.text.length;
    _text.value = TextEditingValue(
      text: _text.text.replaceRange(start, end, snippet),
      selection: TextSelection.collapsed(offset: start + snippet.length),
    );
  }

  void _wrap(String mark) {
    final sel = _text.selection;
    if (!sel.isValid || sel.isCollapsed) return _insert('$mark$mark');
    final inner = sel.textInside(_text.text);
    _text.value = TextEditingValue(
      text: _text.text.replaceRange(sel.start, sel.end, '$mark$inner$mark'),
      selection: TextSelection(baseOffset: sel.start, extentOffset: sel.end + mark.length * 2),
    );
  }

  Future<void> _save() async {
    if (_path != null && ScriptRepository.idFor(_path!) == _name.text) {
      await widget.repository.saveTo(_path!, _text.text);
    } else {
      _path = await widget.repository.save(_name.text, _text.text);
    }
    _dirty = false;
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Guardado en $_path')));
  }

  Future<void> _rehearse() async {
    await _save();
    final script = await widget.repository.load(_path!);
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => PrompterScreen(repository: widget.repository, script: script),
    ));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final est = WpmEstimator.estimate(_parsed, _wpm);
    final neededWpm = _target == null ? null : WpmEstimator.wpmForDuration(_parsed, _target!);

    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.keyS, control: true): _save},
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _name,
            decoration: const InputDecoration(border: InputBorder.none, hintText: 'nombre.md'),
          ),
          actions: [
            IconButton(tooltip: 'Guardar (Ctrl+S)', onPressed: _save, icon: const Icon(Icons.save)),
            IconButton(tooltip: 'Ensayar en el prompter', onPressed: _rehearse, icon: const Icon(Icons.play_arrow)),
          ],
        ),
        body: PopScope(
          canPop: !_dirty,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final leave = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('Cambios sin guardar'),
                content: const Text('¿Salir sin guardar?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
                  TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Salir')),
                ],
              ),
            );
            if (leave == true && context.mounted) {
              _dirty = false;
              Navigator.of(context).pop();
            }
          },
          child: Column(
            children: [
              _Toolbar(onInsert: _insert, onWrap: _wrap),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _text,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 16, height: 1.5),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '# Título\n\n## Sección\n[CAM 1] Texto del guion con **énfasis**. [PAUSE 2s]',
                    ),
                  ),
                ),
              ),
              _StatsBar(
                script: _parsed,
                wpm: _wpm,
                estimate: est,
                target: _target,
                neededWpm: neededWpm,
                onWpm: (v) => setState(() => _wpm = v),
                onTarget: (d) => setState(() => _target = d),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.onInsert, required this.onWrap});
  final void Function(String) onInsert;
  final void Function(String) onWrap;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(children: [
          for (final (label, action) in <(String, VoidCallback)>[
            ('Negrita', () => onWrap('**')),
            ('Resaltar', () => onWrap('==')),
            ('## Sección', () => onInsert('\n## ')),
            ('[CAM 1]', () => onInsert('[CAM 1] ')),
            ('[CAM 2]', () => onInsert('[CAM 2] ')),
            ('Pausa 2s', () => onInsert(' [PAUSE 2s] ')),
            ('Pausa manual', () => onInsert(' [PAUSE] ')),
            ('Cue', () => onInsert('[CUE nombre] ')),
          ])
            Padding(
              padding: const EdgeInsets.all(4),
              child: ActionChip(label: Text(label), onPressed: action),
            ),
        ]),
      );
}

class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.script,
    required this.wpm,
    required this.estimate,
    required this.target,
    required this.neededWpm,
    required this.onWpm,
    required this.onTarget,
  });

  final Script script;
  final double wpm;
  final Duration estimate;
  final Duration? target;
  final double? neededWpm;
  final ValueChanged<double> onWpm;
  final ValueChanged<Duration?> onTarget;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Material(
      color: const Color(0xFF141414),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Wrap(
          spacing: 24,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('${script.wordCount} palabras · ${script.sections.length} marcas', style: t.bodyMedium),
            Text('Duración a ${wpm.round()} WPM: ${formatDuration(estimate)}',
                style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
            SizedBox(
              width: 260,
              child: Slider(
                value: wpm,
                min: 60,
                max: 260,
                divisions: 40,
                label: '${wpm.round()} WPM',
                onChanged: onWpm,
              ),
            ),
            DropdownButton<Duration?>(
              value: target,
              hint: const Text('Duración objetivo'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Sin objetivo')),
                for (final m in [1, 2, 3, 5, 10, 15, 30])
                  DropdownMenuItem(value: Duration(minutes: m), child: Text('$m min')),
              ],
              onChanged: onTarget,
            ),
            if (target != null)
              Text(neededWpm == null ? 'Las pausas superan el objetivo' : 'Necesitas ${neededWpm!.round()} WPM',
                  style: t.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
          ],
        ),
      ),
    );
  }
}
