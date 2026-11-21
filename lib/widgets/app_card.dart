import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final Border? border;
  final VoidCallback? onTap;
  final double radius;
  final bool shadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.padCard),
    this.color,
    this.gradient,
    this.border,
    this.onTap,
    this.radius = AppSpacing.radiusCard,
    this.shadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final radiusValue = BorderRadius.circular(radius);

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? palette.surface) : null,
        gradient: gradient,
        borderRadius: radiusValue,
        border: border ?? Border.all(color: palette.border),
        boxShadow: shadow ? AppSpacing.cardShadow : null,
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: gradient == null ? (color ?? palette.surface) : Colors.transparent,
      borderRadius: radiusValue,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: radiusValue,
            border: border ?? Border.all(color: palette.border),
          ),
          child: child,
        ),
      ),
    );
  }
}
