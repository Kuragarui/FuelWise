import 'package:flutter/material.dart';

import '../models/fuel_log.dart';
import '../services/alert_service.dart';
import '../services/analysis_service.dart';
import '../services/budget_service.dart';
import '../services/prediction_service.dart';
import '../state/app_scope.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';
import '../widgets/alert_banner.dart';
import '../widgets/alert_center_sheet.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/bar_chart_card.dart';
import '../widgets/page_header.dart';
import '../widgets/refuel_details_sheet.dart';
import '../widgets/refuel_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_tile.dart';
import '../widgets/weekly_summary_card.dart';
import 'fuel_budget_screen.dart';
import 'log_refuel_screen.dart';
import 'plan_next_week_screen.dart';
import 'refuel_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;
    final state = AppScope.of(context);
    final profile = state.profile;
    final logs = state.logs;
    final summary = AnalysisService.summarize(logs);
    final monthSummary = AnalysisService.summarizeMonth(logs, DateTime.now());
    final forecast = PredictionService.forecastNextWeek(logs);
    final budget = BudgetService.status(
      logs: logs,
      budget: profile.monthlyBudget,
      projectedSpend: forecast.predictedCost,
    );
    final weeks = AnalysisService.recentWeeks(logs, count: 4);
    final alerts = AlertService.active(
      logs: logs,
      monthlyBudget: profile.monthlyBudget,
      budgetAlerts: state.budgetAlerts,
      priceAlerts: state.priceAlerts,
    );

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
            PageHeader(
              title: '${_greeting(DateTime.now())}, ${profile.firstName}',
              subtitle: profile.location,
              actions: [
                RoundIconButton(
                  icon: alerts.isEmpty
                      ? Icons.notifications_none_rounded
                      : Icons.notifications_active_rounded,
                  foreground: alerts.isEmpty ? null : palette.brandStrong,
                  tooltip: 'Notifications',
                  onTap: () => AlertCenterSheet.show(context),
                ),
                _Avatar(initials: profile.initials),
              ],
            ),
            const SizedBox(height: AppSpacing.gapSection),
            _BudgetHero(
              budget: budget,
              profileVehicle: profile.vehicleName,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const FuelBudgetScreen(),
                ),
              ),
            ),
            if (alerts.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.gapBlock),
              AlertBanner(
                alert: alerts.first,
                onTap: () => _openAlert(context, alerts.first),
              ),
            ],
            const SizedBox(height: AppSpacing.gapSection),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Efficiency',
                    value: summary.avgKmPerL > 0
                        ? '${summary.avgKmPerL.toStringAsFixed(1)} km/L'
                        : '—',
                    caption: summary.avgLPer100km > 0
                        ? '${summary.avgLPer100km.toStringAsFixed(1)} L/100 km'
                        : 'Add a second log',
                    icon: Icons.speed_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    label: 'Avg. price',
                    value: state.averagePrice > 0
                        ? Fmt.price(state.averagePrice)
                        : '—',
                    caption: 'Across ${summary.logCount} refuels',
                    icon: Icons.local_offer_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'This month',
                    value: Fmt.money(monthSummary.totalSpend, decimals: 0),
                    caption: '${Fmt.liters(monthSummary.totalLiters)} logged',
                    icon: Icons.calendar_month_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    label: 'Distance',
                    value:
                        '${summary.logCount > 0 ? _totalKm(logs).toStringAsFixed(0) : 0} km',
                    caption: 'Tracked on your odometer',
                    icon: Icons.route_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.gapSection),
            SectionHeader(
              title: 'Recent refuels',
              actionLabel: 'See all',
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RefuelHistoryScreen(),
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (logs.isEmpty)
              Text('No refuels yet. Add your first one.', style: type.bodySmall)
            else
              ...logs
                  .take(3)
                  .map(
                    (log) => RefuelTile(
                      log: log,
                      onTap: () => RefuelDetailsSheet.show(context, log),
                    ),
                  ),
            const SizedBox(height: AppSpacing.gapBlock),
            AppButton(
              label: 'Log a refuel',
              icon: Icons.add_rounded,
              onTap: () => _openLogRefuel(context),
            ),
            const SizedBox(height: AppSpacing.gapBlock),
            _ForecastCard(
              forecast: forecast,
              averagePrice: state.averagePrice,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PlanNextWeekScreen(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.gapSection),
            ChartCard(
              title: 'Weekly spend',
              subtitle: 'Recent weeks',
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
            if (state.weeklySummary) ...[
              const SizedBox(height: AppSpacing.gapBlock),
              WeeklySummaryCard(logs: logs),
            ],
            const SizedBox(height: AppSpacing.gapBlock),
            _InsightRow(
              title: 'Fuel price trend',
              message: summary.avgPricePerLiter > 0
                  ? 'You pay about ${Fmt.price(summary.avgPricePerLiter)} on average. '
                        'Prices ${_priceDirection(logs)} compared with your last refuel.'
                  : 'Log more refuels to unlock price trend insights.',
              positive: _priceDirection(logs) != 'rose',
            ),
          ],
        ),
      ),
    );
  }

  void _openLogRefuel(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const LogRefuelScreen()));
  }

  void _openAlert(BuildContext context, AppAlert alert) {
    final target = switch (alert.kind) {
      AlertKind.budget => const PlanNextWeekScreen(),
      AlertKind.price => const RefuelHistoryScreen(),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => target));
  }

  String _greeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  double _totalKm(List<FuelLog> logs) {
    return logs.fold<double>(0, (sum, log) => sum + log.kmDriven);
  }

  String _priceDirection(List<FuelLog> logs) {
    if (logs.length < 2) return 'held steady';
    return logs.first.pricePerLiter < logs[1].pricePerLiter
        ? 'fell'
        : logs.first.pricePerLiter > logs[1].pricePerLiter
        ? 'rose'
        : 'held steady';
  }
}

class _BudgetHero extends StatelessWidget {
  final BudgetStatus budget;
  final String profileVehicle;
  final VoidCallback onTap;

  const _BudgetHero({
    required this.budget,
    required this.profileVehicle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: palette.brand,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 16,
                      color: palette.textOnBrand.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'MONTHLY FUEL BUDGET',
                      style: type.overline.copyWith(
                        color: palette.textOnBrand.withValues(alpha: 0.8),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: palette.textOnBrand.withValues(alpha: 0.8),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Fmt.money(budget.spent, decimals: 0),
                      style: type.metric.copyWith(color: palette.textOnBrand),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'of ${Fmt.money(budget.budget, decimals: 0)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: type.caption.copyWith(
                            color: palette.textOnBrand.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  child: Stack(
                    children: [
                      Container(
                        height: 8,
                        color: palette.textOnBrand.withValues(alpha: 0.2),
                      ),
                      FractionallySizedBox(
                        widthFactor: budget.progress.clamp(0.0, 1.0),
                        child: Container(height: 8, color: palette.textOnBrand),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        budget.isOverspent
                            ? '${Fmt.money(budget.remaining.abs(), decimals: 0)} over budget'
                            : '${Fmt.money(budget.remaining, decimals: 0)} left this month',
                        style: type.bodySmall.copyWith(
                          color: palette.textOnBrand,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      profileVehicle,
                      style: type.caption.copyWith(
                        color: palette.textOnBrand.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  final PredictionResult forecast;
  final double averagePrice;
  final VoidCallback onTap;

  const _ForecastCard({
    required this.forecast,
    required this.averagePrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Next week forecast', style: type.cardTitle),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: palette.brandStrong,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            forecast.hasData
                ? 'About ${Fmt.money(forecast.predictedCost, decimals: 0)} for '
                      '${Fmt.liters(forecast.predictedLiters)}'
                : 'Log three refuels to unlock your forecast.',
            style: type.caption,
          ),
          const SizedBox(height: 10),
          Text(
            forecast.hasData
                ? 'Based on ${Fmt.price(averagePrice)} average'
                : 'We will estimate liters and spend for you.',
            style: type.caption.copyWith(color: palette.textMuted),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String title;
  final String message;
  final bool positive;

  const _InsightRow({
    required this.title,
    required this.message,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: positive ? palette.accentSoft : palette.surfaceMuted,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            positive ? Icons.trending_down_rounded : Icons.trending_up_rounded,
            size: 20,
            color: positive ? palette.onAccent : palette.brandStrong,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: type.cardTitle.copyWith(
                    color: positive ? palette.onAccent : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: type.caption.copyWith(
                    color: positive
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

class _Avatar extends StatelessWidget {
  final String initials;

  const _Avatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final type = context.type;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        shape: BoxShape.circle,
        border: Border.all(color: palette.border),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: type.label.copyWith(
          color: palette.brandStrong,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
