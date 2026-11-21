import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';

class BudgetProgress extends StatelessWidget {
  final double progress;
  final double spent;
  final double budget;
  final bool showLabels;
  final double height;

  const BudgetProgress({
    super.key,
    required this.progress,
    required this.spent,
    required this.budget,
    this.showLabels = true,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;
    final over = spent > budget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: Stack(
            children: [
              Container(height: height, color: palette.surfaceStrong),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: over ? palette.danger : palette.brand,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showLabels) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                Fmt.money(spent, decimals: 0),
                style: type.caption.copyWith(color: palette.textSecondary),
              ),
              const Spacer(),
              Text(
                'of ${Fmt.money(budget, decimals: 0)}',
                style: type.caption.copyWith(color: palette.textMuted),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
