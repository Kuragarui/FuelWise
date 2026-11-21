import '../models/fuel_log.dart';

class AnalysisSummary {
  final double totalSpend;
  final double totalLiters;
  final double avgPricePerLiter;
  final double avgKmPerL;
  final double avgLPer100km;
  final int logCount;

  const AnalysisSummary({
    required this.totalSpend,
    required this.totalLiters,
    required this.avgPricePerLiter,
    required this.avgKmPerL,
    required this.avgLPer100km,
    required this.logCount,
  });

  static const empty = AnalysisSummary(
    totalSpend: 0,
    totalLiters: 0,
    avgPricePerLiter: 0,
    avgKmPerL: 0,
    avgLPer100km: 0,
    logCount: 0,
  );
}

class Recommendation {
  final String title;
  final String body;
  final RecommendationTone tone;

  const Recommendation({
    required this.title,
    required this.body,
    this.tone = RecommendationTone.neutral,
  });
}

enum RecommendationTone { positive, caution, neutral }

class AnalysisService {
  AnalysisService._();

  static AnalysisSummary summarize(List<FuelLog> logs) {
    if (logs.isEmpty) return AnalysisSummary.empty;

    final totalSpend = logs.fold<double>(0, (a, l) => a + l.cost);
    final totalLiters = logs.fold<double>(0, (a, l) => a + l.liters);
    final avgPrice = totalLiters > 0 ? totalSpend / totalLiters : 0.0;

    final validEfficiency = logs
        .where((l) => l.kmDriven > 0 && l.liters > 0)
        .toList();

    final validKm = validEfficiency.fold<double>(
      0,
      (sum, log) => sum + log.kmDriven,
    );
    final validLiters = validEfficiency.fold<double>(
      0,
      (sum, log) => sum + log.liters,
    );
    final avgKmPerL = validLiters > 0 ? validKm / validLiters : 0.0;
    final avgLPer100km = validKm > 0 ? (validLiters / validKm) * 100 : 0.0;

    return AnalysisSummary(
      totalSpend: totalSpend,
      totalLiters: totalLiters,
      avgPricePerLiter: avgPrice,
      avgKmPerL: avgKmPerL,
      avgLPer100km: avgLPer100km,
      logCount: logs.length,
    );
  }

  static AnalysisSummary summarizeMonth(List<FuelLog> logs, DateTime month) {
    final monthly = logs.where(
      (log) => log.date.year == month.year && log.date.month == month.month,
    );
    return summarize(monthly.toList());
  }

  static Map<DateTime, List<FuelLog>> groupByWeek(List<FuelLog> logs) {
    final map = <DateTime, List<FuelLog>>{};
    for (final log in logs) {
      final monday = mondayOf(log.date);
      map.putIfAbsent(monday, () => []).add(log);
    }
    final sorted = map.keys.toList()..sort();
    return {for (final k in sorted) k: map[k]!};
  }

  static Map<DateTime, List<FuelLog>> groupByMonth(List<FuelLog> logs) {
    final map = <DateTime, List<FuelLog>>{};
    for (final log in logs) {
      final month = DateTime(log.date.year, log.date.month);
      map.putIfAbsent(month, () => []).add(log);
    }
    final sorted = map.keys.toList()..sort();
    return {for (final k in sorted) k: map[k]!};
  }

  static List<double> weeklyLiters(List<FuelLog> logs) {
    final groups = groupByWeek(logs);
    return groups.values
        .map((week) => week.fold<double>(0, (a, l) => a + l.liters))
        .toList();
  }

  static List<double> weeklySpend(List<FuelLog> logs) {
    final groups = groupByWeek(logs);
    return groups.values
        .map((week) => week.fold<double>(0, (a, l) => a + l.cost))
        .toList();
  }

  static List<double> monthlySpend(List<FuelLog> logs) {
    final groups = groupByMonth(logs);
    return groups.values
        .map((month) => month.fold<double>(0, (a, l) => a + l.cost))
        .toList();
  }

  static List<WeeklyPoint> recentWeeks(List<FuelLog> logs, {int count = 4}) {
    final groups = groupByWeek(logs);
    final keys = groups.keys.toList()..sort();
    final selected = keys.length <= count
        ? keys
        : keys.sublist(keys.length - count);
    return selected.map((week) {
      final entries = groups[week]!;
      return WeeklyPoint(
        weekStart: week,
        liters: entries.fold<double>(0, (a, l) => a + l.liters),
        spend: entries.fold<double>(0, (a, l) => a + l.cost),
      );
    }).toList();
  }

  static List<Recommendation> recommendations(
    List<FuelLog> logs, {
    required double monthlyBudget,
    DateTime? now,
  }) {
    final summary = summarize(logs);
    final result = <Recommendation>[];
    final today = now ?? DateTime.now();

    if (summary.avgKmPerL > 0) {
      result.add(
        Recommendation(
          title:
              'Your average efficiency is ${summary.avgKmPerL.toStringAsFixed(1)} km/L',
          body:
              'That is about ${summary.avgLPer100km.toStringAsFixed(1)} L per 100 km. '
              'Smooth acceleration and steady cruising can stretch this further.',
          tone: RecommendationTone.positive,
        ),
      );
    }

    final currentWeek = mondayOf(today);
    final latestWeekStart = currentWeek.subtract(const Duration(days: 7));
    final previousWeekStart = latestWeekStart.subtract(const Duration(days: 7));
    final latestWeekSpend = _spendBetween(logs, latestWeekStart, currentWeek);
    final previousWeekSpend = _spendBetween(
      logs,
      previousWeekStart,
      latestWeekStart,
    );
    if (previousWeekSpend > 0) {
      final change =
          ((latestWeekSpend - previousWeekSpend) / previousWeekSpend) * 100;
      if (change.abs() >= 5) {
        final up = change > 0;
        result.add(
          Recommendation(
            title: up
                ? 'Weekly spend is up ${change.abs().toStringAsFixed(0)}%'
                : 'Weekly spend is down ${change.abs().toStringAsFixed(0)}%',
            body: up
                ? 'Try consolidating errands or checking price trends before filling up.'
                : 'Nice work. Keep the same route and fuel timing to hold the savings.',
            tone: up ? RecommendationTone.caution : RecommendationTone.positive,
          ),
        );
      }
    }

    final monthSpend = summarizeMonth(logs, today).totalSpend;
    if (monthlyBudget > 0) {
      final used = monthSpend / monthlyBudget;
      if (used >= 0.9) {
        result.add(
          Recommendation(
            title:
                'You have used ${(used * 100).clamp(0, 999).toStringAsFixed(0)}% of your budget',
            body:
                'Reduce non-essential trips for the rest of the month or adjust '
                'your budget in Account to keep alerts realistic.',
            tone: RecommendationTone.caution,
          ),
        );
      } else if (used > 0) {
        result.add(
          Recommendation(
            title: 'Budget is on track',
            body:
                'You have ${((1 - used) * 100).toStringAsFixed(0)}% of this month\'s '
                'fuel budget left. Keep logging every fill-up for accurate forecasts.',
            tone: RecommendationTone.positive,
          ),
        );
      }
    }

    if (logs.length >= 3) {
      final avg = summary.avgPricePerLiter;
      final latestLog = logs.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
      final latest = latestLog.pricePerLiter;
      if (avg > 0) {
        final diff = ((latest - avg) / avg) * 100;
        result.add(
          Recommendation(
            title: diff <= 0
                ? 'Fuel prices are below your average'
                : 'Fuel prices are above your average',
            body:
                'Your latest price is ${diff.abs().toStringAsFixed(1)}% '
                '${diff <= 0 ? 'lower' : 'higher'} than your recorded average '
                'of ${avg.toStringAsFixed(2)} per liter.',
            tone: diff <= 0
                ? RecommendationTone.positive
                : RecommendationTone.neutral,
          ),
        );
      }
    }

    if (result.isEmpty) {
      result.add(
        const Recommendation(
          title: 'Log a few more fill-ups',
          body:
              'Add at least three refuels so FuelWise can compare weeks, spot '
              'price trends, and forecast your next month.',
        ),
      );
    }

    return result;
  }

  static DateTime mondayOf(DateTime d) {
    final daysFromMonday = (d.weekday - 1) % 7;
    final monday = d.subtract(Duration(days: daysFromMonday));
    return DateTime(monday.year, monday.month, monday.day);
  }

  static double _spendBetween(
    List<FuelLog> logs,
    DateTime start,
    DateTime end,
  ) {
    return logs
        .where((log) => !log.date.isBefore(start) && log.date.isBefore(end))
        .fold<double>(0, (sum, log) => sum + log.cost);
  }
}

class WeeklyPoint {
  final DateTime weekStart;
  final double liters;
  final double spend;

  const WeeklyPoint({
    required this.weekStart,
    required this.liters,
    required this.spend,
  });
}
