import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/models/fuel_log.dart';
import 'package:fuelwise/services/prediction_service.dart';

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
  group('LinearRegression', () {
    test('fits a perfect line', () {
      final model = LinearRegression()..fit([0, 1, 2, 3], [2, 4, 6, 8]);
      expect(model.isFitted, isTrue);
      expect(model.slope, closeTo(2, 1e-9));
      expect(model.intercept, closeTo(2, 1e-9));
      expect(model.predict(4), closeTo(10, 1e-9));
    });

    test('handles insufficient data safely', () {
      final model = LinearRegression()..fit([0], [5]);
      expect(model.isFitted, isFalse);
      expect(model.predict(3), 5);
    });
  });

  group('PredictionService', () {
    test('returns no data for fewer than three logs', () {
      final result = PredictionService.forecastNextWeek([
        log(date: DateTime.now()),
        log(date: DateTime.now().subtract(const Duration(days: 7))),
      ]);
      expect(result.hasData, isFalse);
      expect(result.predictedCost, 0);
    });

    test('forecasts next week from weekly buckets', () {
      final now = DateTime.now();
      final logs = [
        for (var i = 0; i < 6; i++)
          log(date: now.subtract(Duration(days: i * 7)), liters: 10, price: 60),
      ];
      final result = PredictionService.forecastNextWeek(logs);
      expect(result.hasData, isTrue);
      expect(result.predictedLiters, greaterThan(0));
      expect(result.predictedCost, greaterThan(0));
      expect(result.periodStart, isNotNull);
      expect(result.periodEnd, isNotNull);
      expect(result.periodEnd!.difference(result.periodStart!).inDays, 6);
    });

    test('forecast values are never negative', () {
      final now = DateTime.now();
      final logs = [
        for (var i = 0; i < 6; i++)
          log(
            date: now.subtract(Duration(days: i * 7)),
            liters: 20.0 - i * 4,
            price: 60,
          ),
      ];
      final result = PredictionService.forecastNextMonth(logs);
      expect(result.predictedLiters, greaterThanOrEqualTo(0));
      expect(result.predictedCost, greaterThanOrEqualTo(0));
    });

    test('respects missing weeks and targets the next calendar week', () {
      final now = DateTime(2026, 10, 19);
      final logs = [
        log(date: DateTime(2026, 9, 28), liters: 10, price: 60),
        log(date: DateTime(2026, 10, 12), liters: 30, price: 60),
        log(date: DateTime(2026, 10, 19), liters: 40, price: 60),
      ];
      final result = PredictionService.forecastNextWeek(logs, now: now);

      expect(result.hasData, isTrue);
      expect(result.predictedLiters, closeTo(50, 0.001));
      expect(result.predictedCost, closeTo(3000, 0.001));
      expect(result.periodStart, DateTime(2026, 10, 26));
      expect(result.periodEnd, DateTime(2026, 11, 1));
    });

    test('targets the next calendar month', () {
      final now = DateTime(2026, 10, 15);
      final logs = [
        log(date: DateTime(2026, 8, 10), liters: 10, price: 60),
        log(date: DateTime(2026, 9, 10), liters: 20, price: 60),
        log(date: DateTime(2026, 10, 10), liters: 30, price: 60),
      ];
      final result = PredictionService.forecastNextMonth(logs, now: now);

      expect(result.hasData, isTrue);
      expect(result.predictedLiters, closeTo(40, 0.001));
      expect(result.periodStart, DateTime(2026, 11, 1));
      expect(result.periodEnd, DateTime(2026, 11, 30));
    });
  });

  group('nextMonday', () {
    test('returns the following Monday', () {
      expect(
        AnalysisServiceDateHelper.nextMonday(DateTime(2026, 10, 19)),
        DateTime(2026, 10, 26),
      );
    });
  });
}
