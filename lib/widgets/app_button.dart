import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool expand;
  final bool loading;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.expand = true,
    this.loading = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;
    final enabled = onTap != null && !loading;

    late final Color background;
    late final Color foreground;
    Border? border;

    switch (variant) {
      case AppButtonVariant.primary:
        background = palette.brand;
        foreground = palette.textOnBrand;
      case AppButtonVariant.secondary:
        background = palette.surface;
        foreground = palette.brand;
        border = Border.all(color: palette.borderStrong);
      case AppButtonVariant.ghost:
        background = Colors.transparent;
        foreground = palette.brand;
      case AppButtonVariant.danger:
        background = palette.danger;
        foreground = Colors.white;
    }

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        else if (icon != null)
          Icon(icon, size: 18, color: foreground),
        if (loading || icon != null) const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: type.button.copyWith(
              color: enabled ? foreground : foreground.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );

    return SizedBox(
      height: height ?? AppSpacing.buttonH,
      width: expand ? double.infinity : null,
      child: Material(
        color: enabled ? background : background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusField),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusField),
          onTap: enabled ? onTap : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusField),
              border: border,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}
