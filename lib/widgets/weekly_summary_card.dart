import 'package:flutter/material.dart';

import '../models/fuel_log.dart';
import '../services/analysis_service.dart';
import '../theme/app_palette.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';
import 'app_card.dart';

class WeeklySummaryCard extends StatelessWidget {
  final List<FuelLog> logs;
  final DateTime? now;

  const WeeklySummaryCard({super.key, required this.logs, this.now});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;
    final today = now ?? DateTime.now();
    final start = AnalysisService.mondayOf(today);
    final end = start.add(const Duration(days: 7));
    final weekLogs = logs
        .where((log) => !log.date.isBefore(start) && log.date.isBefore(end))
        .toList();
    final summary = AnalysisService.summarize(weekLogs);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('This week', style: type.cardTitle)),
              Text(
                Fmt.weekRange(start),
                style: type.caption.copyWith(color: palette.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (weekLogs.isEmpty)
            Text(
              'No refuels logged this week yet.',
              style: type.bodySmall.copyWith(color: palette.textSecondary),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _WeekStat(
                    label: 'Spend',
                    value: Fmt.money(summary.totalSpend, decimals: 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _WeekStat(
                    label: 'Fuel',
                    value: Fmt.liters(summary.totalLiters),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _WeekStat(
                    label: 'Efficiency',
                    value: summary.avgKmPerL > 0
                        ? '${summary.avgKmPerL.toStringAsFixed(1)} km/L'
                        : '—',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _WeekStat extends StatelessWidget {
  final String label;
  final String value;

  const _WeekStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: type.metricSmall.copyWith(color: palette.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(label, style: type.caption, maxLines: 1),
      ],
    );
  }
}
