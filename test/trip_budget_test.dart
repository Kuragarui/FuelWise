import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/models/fuel_log.dart';
import 'package:fuelwise/services/budget_service.dart';
import 'package:fuelwise/services/trip_service.dart';

FuelLog log({required DateTime date, double liters = 10, double price = 60}) {
  return FuelLog(
    date: date,
    liters: liters,
    pricePerLiter: price,
    odometer: 1000,
    kmDriven: 100,
  );
}

void main() {
  group('TripService', () {
    test('estimates one-way distance, liters, and cost', () {
      final estimate = TripService.estimate(
        oneWayKm: 20,
        roundTrip: false,
        kmPerLiter: 10,
        pricePerLiter: 60,
      );
      expect(estimate.distanceKm, 20);
      expect(estimate.liters, closeTo(2, 1e-9));
      expect(estimate.cost, closeTo(120, 1e-9));
    });

    test('doubles distance for round trips', () {
      final estimate = TripService.estimate(
        oneWayKm: 20,
        roundTrip: true,
        kmPerLiter: 10,
        pricePerLiter: 60,
      );
      expect(estimate.distanceKm, 40);
      expect(estimate.liters, closeTo(4, 1e-9));
      expect(estimate.cost, closeTo(240, 1e-9));
    });

    test('returns empty estimate for zero distance', () {
      final estimate = TripService.estimate(
        oneWayKm: 0,
        roundTrip: true,
        kmPerLiter: 10,
        pricePerLiter: 60,
      );
      expect(estimate.cost, 0);
      expect(estimate.liters, 0);
    });
  });

  group('BudgetService', () {
    final now = DateTime(2026, 10, 15);

    test('returns empty when no budget is set', () {
      final status = BudgetService.status(
        logs: [log(date: now)],
        budget: 0,
        projectedSpend: 0,
        now: now,
      );
      expect(status.hasBudget, isFalse);
      expect(status.progress, 0);
    });

    test('computes spent, remaining, and progress for the month', () {
      final status = BudgetService.status(
        logs: [
          log(date: DateTime(2026, 10, 1), liters: 10, price: 60),
          log(date: DateTime(2026, 10, 10), liters: 10, price: 60),
          log(date: DateTime(2026, 9, 28), liters: 50, price: 60),
        ],
        budget: 1500,
        projectedSpend: 0,
        now: now,
      );
      expect(status.spent, closeTo(1200, 0.001));
      expect(status.remaining, closeTo(300, 0.001));
      expect(status.progress, closeTo(0.8, 0.001));
      expect(status.isOverspent, isFalse);
      expect(status.isNearLimit, isFalse);
    });

    test('flags overspending and near-limit states', () {
      final over = BudgetService.status(
        logs: [log(date: now, liters: 20, price: 60)],
        budget: 1000,
        projectedSpend: 0,
        now: now,
      );
      expect(over.isOverspent, isTrue);

      final near = BudgetService.status(
        logs: [log(date: now, liters: 15, price: 60)],
        budget: 1000,
        projectedSpend: 0,
        now: now,
      );
      expect(near.isNearLimit, isTrue);
    });

    test('projects month-end spend from the weekly forecast', () {
      final projected = BudgetService.projectedMonthEnd(
        logs: [
          log(date: DateTime(2026, 10, 5), liters: 10, price: 60),
          log(date: DateTime(2026, 10, 12), liters: 10, price: 60),
          log(date: DateTime(2026, 10, 19), liters: 10, price: 60),
        ],
        weeklyForecast: 1000,
        now: DateTime(2026, 10, 21),
      );
      expect(projected, closeTo(3228.571, 0.001));
    });

    test('averages monthly spend across recent months', () {
      final average = BudgetService.averageMonthlySpend([
        log(date: DateTime(2026, 8, 10), liters: 10, price: 60),
        log(date: DateTime(2026, 9, 10), liters: 20, price: 60),
      ]);
      expect(average, greaterThan(0));
    });
  });
}
