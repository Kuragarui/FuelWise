import 'package:flutter/material.dart';

import '../services/alert_service.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class AlertBanner extends StatelessWidget {
  final AppAlert alert;
  final VoidCallback? onTap;

  const AlertBanner({super.key, required this.alert, this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;

    final (
      IconData icon,
      Color background,
      Color border,
      Color foreground,
    ) = switch (alert.severity) {
      AlertSeverity.danger => (
        Icons.warning_amber_rounded,
        palette.surface,
        palette.danger.withValues(alpha: 0.45),
        palette.danger,
      ),
      AlertSeverity.warning => (
        Icons.info_outline_rounded,
        palette.surface,
        palette.warning.withValues(alpha: 0.4),
        palette.warning,
      ),
      AlertSeverity.positive => (
        Icons.trending_down_rounded,
        palette.accentSoft,
        Colors.transparent,
        palette.onAccent,
      ),
    };

    final content = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: type.cardTitle.copyWith(
                    color: foreground == palette.onAccent ? foreground : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.message,
                  style: type.caption.copyWith(
                    color: foreground == palette.onAccent
                        ? foreground.withValues(alpha: 0.85)
                        : null,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 18, color: foreground),
          ],
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}
