import 'dart:ui' show Color;

/// Ajustes visuales y de lectura. Inmutable: cada cambio crea una copia,
/// lo que permite al motor detectar si hay que re-maquetar el texto.
final class PrompterSettings {
  const PrompterSettings({
    this.fontSize = 64,
    this.lineHeight = 1.35,
    this.horizontalMargin = 0.08,
    this.focusLine = 0.33,
    this.textColor = PrompterPalette.white,
    this.mirrorHorizontal = false,
    this.mirrorVertical = false,
    this.showFocusGuide = true,
    this.wpm = 140,
    this.voiceLanguage = 'es',
    this.highlightSpoken = true,
    this.fontFamily,
  });

  /// Tamaño en píxeles lógicos.
  final double fontSize;

  /// Multiplicador de interlineado.
  final double lineHeight;

  /// Margen lateral como fracción del ancho (0–0.3).
  final double horizontalMargin;

  /// Posición vertical de la línea de enfoque (0 = arriba, 1 = abajo).
  final double focusLine;
  final Color textColor;
  final bool mirrorHorizontal;
  final bool mirrorVertical;
  final bool showFocusGuide;

  /// Velocidad objetivo en palabras por minuto. Se sincroniza en WPM y no
  /// en px/s porque cada dispositivo tiene un tamaño de letra distinto.
  final double wpm;

  /// Idioma del modelo de voz (código de `VoiceModels`).
  final String voiceLanguage;

  /// En modo voz, resalta la palabra dicha y subraya lo leído de la línea.
  final bool highlightSpoken;

  /// Familia tipográfica del guion; `null` = la del sistema.
  final String? fontFamily;

  static const minWpm = 40.0;
  static const maxWpm = 400.0;

  /// ¿Cambia la maquetación (y por tanto las posiciones en px)?
  bool affectsLayout(PrompterSettings o) =>
      o.fontSize != fontSize ||
      o.lineHeight != lineHeight ||
      o.horizontalMargin != horizontalMargin ||
      o.fontFamily != fontFamily;

  PrompterSettings copyWith({
    double? fontSize,
    double? lineHeight,
    double? horizontalMargin,
    double? focusLine,
    Color? textColor,
    bool? mirrorHorizontal,
    bool? mirrorVertical,
    bool? showFocusGuide,
    double? wpm,
    String? voiceLanguage,
    bool? highlightSpoken,
    String? fontFamily,
  }) =>
      PrompterSettings(
        fontSize: (fontSize ?? this.fontSize).clamp(16, 240).toDouble(),
        lineHeight: (lineHeight ?? this.lineHeight).clamp(1.0, 2.5).toDouble(),
        horizontalMargin: (horizontalMargin ?? this.horizontalMargin).clamp(0.0, 0.3).toDouble(),
        focusLine: (focusLine ?? this.focusLine).clamp(0.1, 0.9).toDouble(),
        textColor: textColor ?? this.textColor,
        mirrorHorizontal: mirrorHorizontal ?? this.mirrorHorizontal,
        mirrorVertical: mirrorVertical ?? this.mirrorVertical,
        showFocusGuide: showFocusGuide ?? this.showFocusGuide,
        wpm: (wpm ?? this.wpm).clamp(minWpm, maxWpm).toDouble(),
        voiceLanguage: voiceLanguage ?? this.voiceLanguage,
        highlightSpoken: highlightSpoken ?? this.highlightSpoken,
        fontFamily: fontFamily ?? this.fontFamily,
      );
}

/// Paleta de alto contraste sobre negro profundo (#000, ideal para OLED y
/// para el cristal semirreflectante del teleprompter).
abstract final class PrompterPalette {
  static const background = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const yellow = Color(0xFFFFE14D);
  static const emphasis = Color(0xFFFFE14D);
  static const highlightBg = Color(0xFF3A2F00);
  static const camera = Color(0xFF4DD8FF);
  static const pause = Color(0xFFFF5C7A);
  static const cue = Color(0xFF7CFF8A);
  static const focusGuide = Color(0x33FFFFFF);

  /// Azul neón de la marca GNUXDAR: resaltado de lo que se va diciendo.
  static const spoken = Color(0xFF00E5FF);
  static const dim = Color(0xFF8A8A8A);
}
