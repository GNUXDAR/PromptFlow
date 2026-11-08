import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../remote/protocol/messages.dart';

/// Mapa de teclado y pedales Bluetooth (Módulo C).
///
/// Los pedales BT se presentan como teclado HID; en Linux y en Android llegan
/// como eventos de tecla normales, así que el mismo mapa sirve para ambos.
/// Perfiles habituales: PgUp/PgDn (pedales de pasar página), Space, flechas.
final Map<ShortcutActivator, PrompterCommand> prompterKeymap = {
  // Play/Pause
  const SingleActivator(LogicalKeyboardKey.space): const ToggleCommand(),
  const SingleActivator(LogicalKeyboardKey.mediaPlayPause): const ToggleCommand(),
  const SingleActivator(LogicalKeyboardKey.enter): const ToggleCommand(),
  // Pedales de página: atrás / adelante 5 s
  const SingleActivator(LogicalKeyboardKey.pageUp): const SeekCommand(-5),
  const SingleActivator(LogicalKeyboardKey.pageDown): const SeekCommand(5),
  const SingleActivator(LogicalKeyboardKey.arrowLeft): const SeekCommand(-5),
  const SingleActivator(LogicalKeyboardKey.arrowRight): const SeekCommand(5),
  const SingleActivator(LogicalKeyboardKey.mediaRewind): const SeekCommand(-5),
  const SingleActivator(LogicalKeyboardKey.mediaFastForward): const SeekCommand(5),
  // Velocidad
  const SingleActivator(LogicalKeyboardKey.arrowUp): const NudgeSpeedCommand(10),
  const SingleActivator(LogicalKeyboardKey.arrowDown): const NudgeSpeedCommand(-10),
  // Mirroring y fuente
  const SingleActivator(LogicalKeyboardKey.keyH): const ToggleMirrorCommand(MirrorAxis.horizontal),
  const SingleActivator(LogicalKeyboardKey.keyV): const ToggleMirrorCommand(MirrorAxis.vertical),
  const SingleActivator(LogicalKeyboardKey.equal): const FontNudgeCommand(4),
  const SingleActivator(LogicalKeyboardKey.minus): const FontNudgeCommand(-4),
  // Inicio del guion
  const SingleActivator(LogicalKeyboardKey.home): const GotoWordCommand(0),
};

/// Envuelve la vista del prompter y traduce teclas a comandos.
class PrompterShortcuts extends StatelessWidget {
  const PrompterShortcuts({super.key, required this.onCommand, required this.child, this.extra = const {}});

  final void Function(PrompterCommand) onCommand;
  final Map<ShortcutActivator, VoidCallback> extra;
  final Widget child;

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
        bindings: {
          for (final e in prompterKeymap.entries) e.key: () => onCommand(e.value),
          ...extra,
        },
        child: Focus(autofocus: true, child: child),
      );
}
