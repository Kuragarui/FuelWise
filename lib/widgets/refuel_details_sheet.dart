import 'package:flutter/material.dart';

import '../models/fuel_log.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';

class RefuelDetailsSheet extends StatelessWidget {
  final FuelLog log;

  const RefuelDetailsSheet({super.key, required this.log});

  static Future<void> show(BuildContext context, FuelLog log) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => RefuelDetailsSheet(log: log),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.padSide,
          12,
          AppSpacing.padSide,
          24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.borderStrong,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: AppSpacing.iconTile,
                    height: AppSpacing.iconTile,
                    decoration: BoxDecoration(
                      color: palette.accentSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_gas_station_rounded,
                      size: 20,
                      color: palette.onAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.station ?? 'Fuel stop',
                          style: type.section,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(Fmt.dateTime(log.date), style: type.caption),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: palette.brand,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL COST',
                            style: type.overline.copyWith(
                              color: palette.textOnBrand.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Fmt.money(log.cost),
                            style: type.metric.copyWith(
                              color: palette.textOnBrand,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Fmt.liters(log.liters),
                      style: type.section.copyWith(color: palette.textOnBrand),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _DetailRow(
                label: 'Price per liter',
                value: Fmt.price(log.pricePerLiter),
              ),
              _DetailRow(label: 'Odometer', value: '${log.odometer} km'),
              _DetailRow(
                label: 'Distance since last',
                value: log.kmDriven > 0
                    ? '${log.kmDriven.toStringAsFixed(0)} km'
                    : '—',
              ),
              if (log.notes != null && log.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Notes', style: type.label),
                const SizedBox(height: 6),
                Text(log.notes!, style: type.body),
              ],
              const SizedBox(height: 20),
              Text(
                'Tap outside to close.',
                style: type.caption.copyWith(color: palette.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: type.caption)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: type.label.copyWith(color: palette.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
