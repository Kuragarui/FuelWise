import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => _build(AppPalette.dark);

  static ThemeData _build(AppPalette palette) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.brand,
        brightness: Brightness.dark,
        primary: palette.brand,
        onPrimary: palette.textOnBrand,
        secondary: palette.accent,
        surface: palette.surface,
        onSurface: palette.textPrimary,
        error: palette.danger,
        outline: palette.borderStrong,
      ),
      scaffoldBackgroundColor: palette.canvas,
      canvasColor: palette.canvas,
      splashFactory: InkSparkle.splashFactory,
      dividerColor: palette.border,
      extensions: <ThemeExtension<dynamic>>[
        palette,
        AppTypography.build(
          palette.textPrimary,
          palette.textSecondary,
          palette.textMuted,
        ),
      ],
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: palette.textPrimary, size: 22),
        titleTextStyle: base.extension<AppTypography>()!.title,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          side: BorderSide(color: palette.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceMuted,
        hintStyle: base.extension<AppTypography>()!.body.copyWith(
          color: palette.textMuted,
        ),
        labelStyle: base.extension<AppTypography>()!.label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusField),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusField),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusField),
          borderSide: BorderSide(color: palette.brandStrong, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusField),
          borderSide: BorderSide(color: palette.danger),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.brand,
        contentTextStyle: base.extension<AppTypography>()!.body.copyWith(
          color: palette.textOnBrand,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusField),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Color.alphaBlend(palette.surface, palette.canvas),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Color.alphaBlend(palette.surface, palette.canvas),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.textOnBrand
              : palette.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.brand
              : palette.surfaceStrong,
        ),
        trackOutlineColor: WidgetStatePropertyAll(palette.border),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.brand,
        linearTrackColor: palette.surfaceStrong,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: palette.brandStrong,
        selectionColor: palette.accent.withValues(alpha: 0.4),
        selectionHandleColor: palette.brand,
      ),
    );
  }
}
