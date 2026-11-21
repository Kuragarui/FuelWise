import '../models/fuel_log.dart';
import '../utils/formatters.dart';
import 'budget_service.dart';
import 'prediction_service.dart';

enum AlertKind { budget, price }

enum AlertSeverity { danger, warning, positive }

class AppAlert {
  final AlertKind kind;
  final AlertSeverity severity;
  final String title;
  final String message;

  const AppAlert({
    required this.kind,
    required this.severity,
    required this.title,
    required this.message,
  });
}

class AlertService {
  AlertService._();

  static List<AppAlert> active({
    required List<FuelLog> logs,
    required double monthlyBudget,
    required bool budgetAlerts,
    required bool priceAlerts,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final alerts = <AppAlert>[];

    if (budgetAlerts && monthlyBudget > 0) {
      final forecast = PredictionService.forecastNextWeek(logs, now: today);
      final spent = BudgetService.monthSpent(logs, now: today);
      final projected = BudgetService.projectedMonthEnd(
        logs: logs,
        weeklyForecast: forecast.predictedCost,
        now: today,
      );

      if (spent > monthlyBudget) {
        alerts.add(
          AppAlert(
            kind: AlertKind.budget,
            severity: AlertSeverity.danger,
            title: 'Over your fuel budget',
            message:
                'You have spent ${Fmt.money(spent, decimals: 0)} of '
                '${Fmt.money(monthlyBudget, decimals: 0)} this month, '
                '${Fmt.money(spent - monthlyBudget, decimals: 0)} over.',
          ),
        );
      } else if (projected > monthlyBudget) {
        alerts.add(
          AppAlert(
            kind: AlertKind.budget,
            severity: AlertSeverity.danger,
            title: 'Forecast exceeds your budget',
            message:
                'At your current pace, you may spend '
                '${Fmt.money(projected, decimals: 0)} by month end, '
                '${Fmt.money(projected - monthlyBudget, decimals: 0)} over '
                'your ${Fmt.money(monthlyBudget, decimals: 0)} budget.',
          ),
        );
      } else if (projected >= monthlyBudget * 0.9) {
        alerts.add(
          AppAlert(
            kind: AlertKind.budget,
            severity: AlertSeverity.warning,
            title: 'Approaching your fuel budget',
            message:
                'Your forecast puts you at ${Fmt.money(projected, decimals: 0)} '
                'of ${Fmt.money(monthlyBudget, decimals: 0)} by month end.',
          ),
        );
      }
    }

    if (priceAlerts && logs.length >= 2) {
      final sorted = [...logs]..sort((a, b) => a.date.compareTo(b.date));
      final previous = sorted[sorted.length - 2];
      final latest = sorted.last;
      if (latest.pricePerLiter < previous.pricePerLiter) {
        final drop = previous.pricePerLiter - latest.pricePerLiter;
        alerts.add(
          AppAlert(
            kind: AlertKind.price,
            severity: AlertSeverity.positive,
            title: 'Fuel price dropped',
            message:
                'Your latest fill-up was ${Fmt.price(latest.pricePerLiter)}, '
                '${Fmt.money(drop)} per liter lower than the previous one.',
          ),
        );
      }
    }

    return alerts;
  }
}
