import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/models/fuel_log.dart';
import 'package:fuelwise/services/alert_service.dart';

FuelLog log({required DateTime date, double liters = 10, double price = 100}) {
  return FuelLog(
    date: date,
    liters: liters,
    pricePerLiter: price,
    odometer: 1000,
    kmDriven: 100,
  );
}

void main() {
  final now = DateTime(2026, 10, 21);

  List<FuelLog> budgetLogs() => [
    log(date: DateTime(2026, 10, 5)),
    log(date: DateTime(2026, 10, 12)),
    log(date: DateTime(2026, 10, 19)),
  ];

  group('AlertService budget alerts', () {
    test('warns when the forecast approaches the monthly budget', () {
      final alerts = AlertService.active(
        logs: budgetLogs(),
        monthlyBudget: 4800,
        budgetAlerts: true,
        priceAlerts: false,
        now: now,
      );

      expect(alerts, hasLength(1));
      expect(alerts.single.kind, AlertKind.budget);
      expect(alerts.single.severity, AlertSeverity.warning);
      expect(alerts.single.title, 'Approaching your fuel budget');
    });

    test('warns when projected spend exceeds the budget', () {
      final alerts = AlertService.active(
        logs: budgetLogs(),
        monthlyBudget: 4000,
        budgetAlerts: true,
        priceAlerts: false,
        now: now,
      );

      expect(alerts.single.severity, AlertSeverity.danger);
      expect(alerts.single.title, 'Forecast exceeds your budget');
    });

    test('does not warn when budget alerts are off', () {
      final alerts = AlertService.active(
        logs: budgetLogs(),
        monthlyBudget: 1000,
        budgetAlerts: false,
        priceAlerts: false,
        now: now,
      );

      expect(alerts, isEmpty);
    });
  });

  group('AlertService price alerts', () {
    test('warns when the latest price is lower', () {
      final alerts = AlertService.active(
        logs: [
          log(date: DateTime(2026, 1, 1), price: 60),
          log(date: DateTime(2026, 1, 8), price: 58),
        ],
        monthlyBudget: 0,
        budgetAlerts: false,
        priceAlerts: true,
        now: DateTime(2026, 1, 10),
      );

      expect(alerts, hasLength(1));
      expect(alerts.single.kind, AlertKind.price);
      expect(alerts.single.severity, AlertSeverity.positive);
      expect(alerts.single.title, 'Fuel price dropped');
    });

    test('does not warn when prices rise', () {
      final alerts = AlertService.active(
        logs: [
          log(date: DateTime(2026, 1, 1), price: 58),
          log(date: DateTime(2026, 1, 8), price: 60),
        ],
        monthlyBudget: 0,
        budgetAlerts: false,
        priceAlerts: true,
        now: DateTime(2026, 1, 10),
      );

      expect(alerts, isEmpty);
    });
  });
}
