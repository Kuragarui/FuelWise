import 'package:flutter/material.dart';

import '../models/fuel_log.dart';
import '../services/analysis_service.dart';
import '../state/app_scope.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';
import '../widgets/bar_chart_card.dart';
import '../widgets/page_header.dart';
import '../widgets/section_header.dart';
import '../widgets/segmented_control.dart';
import '../widgets/stat_tile.dart';
import 'refuel_history_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _weekly = true;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;
    final state = AppScope.of(context);
    final logs = state.logs;
    final summary = AnalysisService.summarize(logs);
    final recommendations = AnalysisService.recommendations(
      logs,
      monthlyBudget: state.profile.monthlyBudget,
    );

    final points = _buildPoints(logs);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.padSide,
          12,
          AppSpacing.padSide,
          32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Analytics',
              subtitle: 'Understand your fuel habits',
            ),
            const SizedBox(height: AppSpacing.gapSection),
            SegmentedControl<bool>(
              options: const [
                SegmentOption(true, 'Weekly'),
                SegmentOption(false, 'Monthly'),
              ],
              value: _weekly,
              onChanged: (value) => setState(() => _weekly = value),
            ),
            const SizedBox(height: AppSpacing.gapBlock),
            ChartCard(
              title: _weekly ? 'Fuel used per week' : 'Fuel used per month',
              subtitle: _weekly ? 'Liters, recent weeks' : 'Liters, by month',
              child: BarChartCard(
                points: points,
                highlightIndex: points.isEmpty ? null : points.length - 1,
              ),
            ),
            const SizedBox(height: AppSpacing.gapBlock),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Avg. efficiency',
                    value: summary.avgKmPerL > 0
                        ? '${summary.avgKmPerL.toStringAsFixed(1)} km/L'
                        : '—',
                    caption: 'Higher is better',
                    icon: Icons.speed_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    label: 'Consumption',
                    value: summary.avgLPer100km > 0
                        ? '${summary.avgLPer100km.toStringAsFixed(1)} L/100'
                        : '—',
                    caption: 'Lower is better',
                    icon: Icons.local_gas_station_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Total spend',
                    value: Fmt.money(summary.totalSpend, decimals: 0),
                    caption: 'All logged refuels',
                    icon: Icons.payments_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    label: 'Total liters',
                    value: Fmt.liters(summary.totalLiters),
                    caption: 'Fuel purchased',
                    icon: Icons.opacity_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.gapSection),
            SectionHeader(
              title: 'Recommendations',
              actionLabel: 'History',
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RefuelHistoryScreen(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...recommendations.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RecommendationCard(item: item),
              ),
            ),
            const SizedBox(height: AppSpacing.gapBlock),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: palette.surfaceMuted,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 20,
                    color: palette.brandStrong,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Insights update automatically as you log refuels. '
                      'Aim for consistent odometer readings for the best accuracy.',
                      style: type.caption.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ChartPoint> _buildPoints(List<FuelLog> logs) {
    if (_weekly) {
      final weeks = AnalysisService.recentWeeks(logs, count: 4);
      return weeks
          .map(
            (week) => ChartPoint(
              label: Fmt.weekRange(week.weekStart, separator: ' to '),
              value: week.liters,
            ),
          )
          .toList();
    }
    final months = AnalysisService.groupByMonth(logs);
    final keys = months.keys.toList()..sort();
    final selected = keys.length <= 4 ? keys : keys.sublist(keys.length - 4);
    return selected
        .map(
          (month) => ChartPoint(
            label: Fmt.monthLong(month),
            value: months[month]!.fold<double>(0, (a, l) => a + l.liters),
          ),
        )
        .toList();
  }
}

class _RecommendationCard extends StatelessWidget {
  final Recommendation item;

  const _RecommendationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;

    final (IconData icon, Color background) = switch (item.tone) {
      RecommendationTone.positive => (
        Icons.trending_down_rounded,
        palette.accentSoft,
      ),
      RecommendationTone.caution => (
        Icons.warning_amber_rounded,
        palette.surfaceMuted,
      ),
      RecommendationTone.neutral => (
        Icons.insights_rounded,
        palette.surfaceMuted,
      ),
    };
    final onLime = item.tone == RecommendationTone.positive;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: onLime ? palette.onAccent : palette.brandStrong,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: type.cardTitle.copyWith(
                    color: onLime ? palette.onAccent : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: type.caption.copyWith(
                    color: onLime
                        ? palette.onAccent.withValues(alpha: 0.85)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
