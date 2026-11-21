import 'package:flutter/material.dart';

import '../models/fuel_log.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';

class RefuelTile extends StatelessWidget {
  final FuelLog log;
  final bool showDivider;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const RefuelTile({
    super.key,
    required this.log,
    this.showDivider = true,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;

    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: AppSpacing.iconTile,
            height: AppSpacing.iconTile,
            decoration: BoxDecoration(
              color: palette.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_gas_station_rounded,
              color: palette.brandStrong,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.station ?? 'Fuel stop',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: type.cardTitle,
                ),
                const SizedBox(height: 2),
                Text(
                  '${Fmt.relativeDate(log.date)} · ${log.liters.toStringAsFixed(1)} L',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: type.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Fmt.money(log.cost),
                style: type.label.copyWith(color: palette.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(Fmt.price(log.pricePerLiter), style: type.caption),
            ],
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onDelete,
              tooltip: 'Delete refuel',
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: palette.textMuted,
              ),
            ),
          ],
        ],
      ),
    );

    final content = onTap == null
        ? tile
        : InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            child: tile,
          );

    if (!showDivider) return content;

    return Column(
      children: [
        content,
        Divider(height: 1, color: palette.border),
      ],
    );
  }
}
