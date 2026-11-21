import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/models/fuel_log.dart';
import 'package:fuelwise/services/analysis_service.dart';

FuelLog log({
  required DateTime date,
  double liters = 10,
  double price = 60,
  int odometer = 1000,
  double kmDriven = 100,
}) {
  return FuelLog(
    date: date,
    liters: liters,
    pricePerLiter: price,
    odometer: odometer,
    kmDriven: kmDriven,
  );
}

void main() {
  group('AnalysisService.summarize', () {
    test('returns empty summary for no logs', () {
      final summary = AnalysisService.summarize([]);
      expect(summary.totalSpend, 0);
      expect(summary.totalLiters, 0);
      expect(summary.logCount, 0);
    });

    test('computes spend, liters, and weighted average price', () {
      final logs = [
        log(date: DateTime(2026, 1, 5), liters: 10, price: 60),
        log(date: DateTime(2026, 1, 12), liters: 20, price: 63),
      ];
      final summary = AnalysisService.summarize(logs);
      expect(summary.totalSpend, closeTo(1860, 0.001));
      expect(summary.totalLiters, 30);
      expect(summary.avgPricePerLiter, closeTo(62, 0.001));
      expect(summary.logCount, 2);
    });

    test('computes efficiency from logs with distance', () {
      final logs = [
        log(date: DateTime(2026, 1, 5), liters: 10, kmDriven: 100),
        log(date: DateTime(2026, 1, 12), liters: 10, kmDriven: 150),
      ];
      final summary = AnalysisService.summarize(logs);
      expect(summary.avgKmPerL, closeTo(12.5, 0.001));
      expect(summary.avgLPer100km, closeTo(8, 0.001));
    });

    test('weights efficiency by distance and liters', () {
      final logs = [
        log(date: DateTime(2026, 1, 5), liters: 5, kmDriven: 100),
        log(date: DateTime(2026, 1, 12), liters: 15, kmDriven: 200),
      ];
      final summary = AnalysisService.summarize(logs);
      expect(summary.avgKmPerL, closeTo(15, 0.001));
      expect(summary.avgLPer100km, closeTo(6.667, 0.001));
    });
  });

  group('grouping', () {
    test('groups by month in sorted order', () {
      final logs = [
        log(date: DateTime(2026, 3, 5)),
        log(date: DateTime(2026, 1, 20)),
        log(date: DateTime(2026, 3, 25)),
      ];
      final grouped = AnalysisService.groupByMonth(logs);
      expect(grouped.keys.toList(), [DateTime(2026, 1), DateTime(2026, 3)]);
      expect(grouped[DateTime(2026, 3)]!.length, 2);
    });

    test('recentWeeks returns at most the requested count', () {
      final logs = [
        for (var i = 0; i < 8; i++)
          log(date: DateTime(2026, 1, 1).add(Duration(days: i * 7))),
      ];
      final weeks = AnalysisService.recentWeeks(logs, count: 4);
      expect(weeks.length, 4);
      expect(weeks.last.weekStart.isAfter(weeks.first.weekStart), isTrue);
    });
  });

  group('recommendations', () {
    test('produces guidance for a budget near the limit', () {
      final now = DateTime.now();
      final logs = [log(date: now, liters: 40, price: 60, kmDriven: 400)];
      final items = AnalysisService.recommendations(logs, monthlyBudget: 2000);
      expect(items, isNotEmpty);
      expect(items.any((item) => item.title.contains('budget')), isTrue);
    });

    test('uses the weighted price and the latest log by date', () {
      final now = DateTime(2026, 1, 25);
      final logs = [
        log(date: DateTime(2026, 1, 10), liters: 10, price: 60),
        log(date: DateTime(2026, 1, 20), liters: 30, price: 70),
        log(date: DateTime(2026, 1, 5), liters: 10, price: 50),
      ];
      final items = AnalysisService.recommendations(
        logs,
        monthlyBudget: 5000,
        now: now,
      );
      final priceItem = items.firstWhere(
        (item) => item.title.contains('Fuel prices'),
      );
      expect(priceItem.title, 'Fuel prices are above your average');
      expect(priceItem.body, contains('of 64.00 per liter'));
    });

    test('compares completed weeks instead of the partial current week', () {
      final now = DateTime(2026, 10, 21);
      final logs = [
        log(date: DateTime(2026, 10, 14), liters: 10, price: 120),
        log(date: DateTime(2026, 10, 7), liters: 10, price: 50),
        log(date: DateTime(2026, 10, 21), liters: 10, price: 10),
      ];
      final items = AnalysisService.recommendations(
        logs,
        monthlyBudget: 5000,
        now: now,
      );
      expect(
        items.any((item) => item.title.contains('Weekly spend is up')),
        isTrue,
      );
    });
  });
}
