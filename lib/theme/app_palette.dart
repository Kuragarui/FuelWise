import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color canvas;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceStrong;
  final Color brand;
  final Color brandStrong;
  final Color accent;
  final Color accentSoft;
  final Color onAccent;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textOnBrand;
  final Color border;
  final Color borderStrong;
  final Color danger;
  final Color warning;
  final Color success;
  final Color chartBar;
  final Color chartBarMuted;
  final Color glowTop;
  final Color glowBottom;
  final Color navBackground;
  final Color navActive;
  final Color navInactive;
  final Color shadow;

  const AppPalette({
    required this.canvas,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceStrong,
    required this.brand,
    required this.brandStrong,
    required this.accent,
    required this.accentSoft,
    required this.onAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textOnBrand,
    required this.border,
    required this.borderStrong,
    required this.danger,
    required this.warning,
    required this.success,
    required this.chartBar,
    required this.chartBarMuted,
    required this.glowTop,
    required this.glowBottom,
    required this.navBackground,
    required this.navActive,
    required this.navInactive,
    required this.shadow,
  });

  static const AppPalette dark = AppPalette(
    canvas: Color(0xFF241C44),
    surface: Color(0x45A692EE),
    surfaceMuted: Color(0x30D0F282),
    surfaceStrong: Color(0x66A692EE),
    brand: Color(0xFFD0F282),
    brandStrong: Color(0xFFCEFF5E),
    accent: Color(0xFFCEFF5E),
    accentSoft: Color(0xFFD0F282),
    onAccent: Color(0xFF241C44),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xD1FFFFFF),
    textMuted: Color(0xB3FFFFFF),
    textOnBrand: Color(0xFF1E1E1E),
    border: Color(0x33FFFFFF),
    borderStrong: Color(0x80FFFFFF),
    danger: Color(0xFFFFB4AB),
    warning: Color(0xFFFFD08A),
    success: Color(0xFFCEFF5E),
    chartBar: Color(0xFFD0F282),
    chartBarMuted: Color(0x66D0F282),
    glowTop: Color(0xB3734EF3),
    glowBottom: Color(0xB3A692EE),
    navBackground: Color(0x3302000B),
    navActive: Color(0xBDD0F282),
    navInactive: Color(0xFFDFDFEC),
    shadow: Color(0x4D000000),
  );

  @override
  AppPalette copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceStrong,
    Color? brand,
    Color? brandStrong,
    Color? accent,
    Color? accentSoft,
    Color? onAccent,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textOnBrand,
    Color? border,
    Color? borderStrong,
    Color? danger,
    Color? warning,
    Color? success,
    Color? chartBar,
    Color? chartBarMuted,
    Color? glowTop,
    Color? glowBottom,
    Color? navBackground,
    Color? navActive,
    Color? navInactive,
    Color? shadow,
  }) {
    return AppPalette(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      brand: brand ?? this.brand,
      brandStrong: brandStrong ?? this.brandStrong,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      onAccent: onAccent ?? this.onAccent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textOnBrand: textOnBrand ?? this.textOnBrand,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      chartBar: chartBar ?? this.chartBar,
      chartBarMuted: chartBarMuted ?? this.chartBarMuted,
      glowTop: glowTop ?? this.glowTop,
      glowBottom: glowBottom ?? this.glowBottom,
      navBackground: navBackground ?? this.navBackground,
      navActive: navActive ?? this.navActive,
      navInactive: navInactive ?? this.navInactive,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      surfaceStrong: Color.lerp(surfaceStrong, other.surfaceStrong, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      brandStrong: Color.lerp(brandStrong, other.brandStrong, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textOnBrand: Color.lerp(textOnBrand, other.textOnBrand, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      chartBar: Color.lerp(chartBar, other.chartBar, t)!,
      chartBarMuted: Color.lerp(chartBarMuted, other.chartBarMuted, t)!,
      glowTop: Color.lerp(glowTop, other.glowTop, t)!,
      glowBottom: Color.lerp(glowBottom, other.glowBottom, t)!,
      navBackground: Color.lerp(navBackground, other.navBackground, t)!,
      navActive: Color.lerp(navActive, other.navActive, t)!,
      navInactive: Color.lerp(navInactive, other.navInactive, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension PaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
