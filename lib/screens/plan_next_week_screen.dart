import 'package:flutter/material.dart';

import '../services/analysis_service.dart';
import '../services/budget_service.dart';
import '../services/prediction_service.dart';
import '../state/app_scope.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/bar_chart_card.dart';
import '../widgets/glow_background.dart';
import '../widgets/page_header.dart';
import 'fuel_budget_screen.dart';

class PlanNextWeekScreen extends StatelessWidget {
  static const String routeName = '/plan';

  const PlanNextWeekScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;
    final state = AppScope.of(context);
    final forecast = PredictionService.forecastNextWeek(state.logs);
    final weeks = AnalysisService.recentWeeks(state.logs, count: 4);
    final monthSpent = BudgetService.monthSpent(state.logs);
    final projectedMonth = BudgetService.projectedMonthEnd(
      logs: state.logs,
      weeklyForecast: forecast.predictedCost,
    );
    final budget = BudgetService.status(
      logs: state.logs,
      budget: state.profile.monthlyBudget,
      projectedSpend: projectedMonth - monthSpent,
    );

    final trend = forecast.trendSlope;
    final trendUp = trend > 0;

    return Scaffold(
      backgroundColor: palette.canvas,
      body: GlowBackground(
        variant: GlowVariant.pageTop,
        child: SafeArea(
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
                  title: 'Plan for next week',
                  subtitle: 'A forecast based on your refuels',
                  showBack: true,
                ),
                const SizedBox(height: AppSpacing.gapSection),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: palette.brand,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        forecast.periodStart != null
                            ? '${Fmt.dateShort(forecast.periodStart!)} – ${Fmt.dateShort(forecast.periodEnd!)}'
                            : 'Next week',
                        style: type.caption.copyWith(
                          color: palette.textOnBrand.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        forecast.hasData
                            ? Fmt.money(forecast.predictedCost, decimals: 0)
                            : '—',
                        style: type.metric.copyWith(color: palette.textOnBrand),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        forecast.hasData
                            ? '${Fmt.liters(forecast.predictedLiters)} estimated fuel'
                            : 'Log at least three refuels to unlock a forecast.',
                        style: type.bodySmall.copyWith(
                          color: palette.textOnBrand.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _HeroStat(
                              label: 'Spend trend',
                              value: forecast.hasData
                                  ? trendUp
                                        ? 'Rising'
                                        : 'Falling'
                                  : '—',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _HeroStat(
                              label: 'Projected use',
                              value: budget.hasBudget
                                  ? '${(budget.projected / budget.budget * 100).clamp(0, 999).toStringAsFixed(0)}%'
                                  : '—',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _HeroStat(
                              label: 'Avg. weekly',
                              value: weeks.isEmpty
                                  ? '—'
                                  : Fmt.money(
                                      weeks.fold<double>(
                                            0,
                                            (a, w) => a + w.spend,
                                          ) /
                                          weeks.length,
                                      decimals: 0,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.gapBlock),
                ChartCard(
                  title: 'Recent weeks',
                  subtitle: 'Spend per week',
                  child: BarChartCard(
                    points: weeks
                        .map(
                          (week) => ChartPoint(
                            label: Fmt.weekRange(week.weekStart),
                            value: week.spend,
                          ),
                        )
                        .toList(),
                    highlightIndex: weeks.isEmpty ? null : weeks.length - 1,
                    showYAxis: true,
                    axisFormatter: Fmt.axisMoney,
                  ),
                ),
                const SizedBox(height: AppSpacing.gapBlock),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How we calculate this', style: type.cardTitle),
                      const SizedBox(height: 6),
                      Text(
                        'FuelWise groups your refuels by week and fits a straight '
                        'line through your spend and liters. The next point on that '
                        'line becomes your forecast. More logs make it more accurate.',
                        style: type.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.gapBlock),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: palette.accentSoft,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 20,
                        color: palette.onAccent,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trendUp
                                  ? 'Spending may increase next week'
                                  : 'Spending looks stable next week',
                              style: type.cardTitle.copyWith(
                                color: palette.onAccent,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              trendUp
                                  ? 'Plan errands together or compare stations before '
                                        'your next fill-up to stay inside your budget.'
                                  : 'Keep logging every refuel so the trend stays reliable.',
                              style: type.caption.copyWith(
                                color: palette.onAccent.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.gapSection),
                AppButton(
                  label: 'Adjust budget',
                  icon: Icons.account_balance_wallet_outlined,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const FuelBudgetScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: type.caption.copyWith(
            color: palette.textOnBrand.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: type.label.copyWith(color: palette.textOnBrand)),
      ],
    );
  }
}
