import '../models/fuel_log.dart';

class LinearRegression {
  double slope = 0;
  double intercept = 0;
  bool _fitted = false;

  bool get isFitted => _fitted;

  void fit(List<double> x, List<double> y) {
    if (x.length != y.length || x.length < 2) {
      slope = 0;
      intercept = y.isEmpty ? 0 : y.first;
      _fitted = false;
      return;
    }

    final n = x.length;
    final meanX = x.reduce((a, b) => a + b) / n;
    final meanY = y.reduce((a, b) => a + b) / n;

    double num = 0;
    double den = 0;
    for (var i = 0; i < n; i++) {
      num += (x[i] - meanX) * (y[i] - meanY);
      den += (x[i] - meanX) * (x[i] - meanX);
    }

    slope = den == 0 ? 0 : num / den;
    intercept = meanY - slope * meanX;
    _fitted = true;
  }

  double predict(double x) => intercept + slope * x;
}

class PredictionResult {
  final double predictedLiters;
  final double predictedCost;
  final double trendSlope;
  final bool hasData;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  const PredictionResult({
    required this.predictedLiters,
    required this.predictedCost,
    required this.trendSlope,
    required this.hasData,
    this.periodStart,
    this.periodEnd,
  });

  static const empty = PredictionResult(
    predictedLiters: 0,
    predictedCost: 0,
    trendSlope: 0,
    hasData: false,
  );
}

class PredictionService {
  PredictionService._();

  static PredictionResult forecastNextWeek(
    List<FuelLog> logs, {
    DateTime? now,
  }) {
    return _forecast(
      logs,
      aggregator: _weeklyAggregator,
      isWeekly: true,
      now: now,
    );
  }

  static PredictionResult forecastNextMonth(
    List<FuelLog> logs, {
    DateTime? now,
  }) {
    return _forecast(
      logs,
      aggregator: _monthlyAggregator,
      isWeekly: false,
      now: now,
    );
  }

  static PredictionResult _forecast(
    List<FuelLog> logs, {
    required Map<int, _Agg> Function(List<FuelLog>) aggregator,
    required bool isWeekly,
    DateTime? now,
  }) {
    if (logs.length < 3) return PredictionResult.empty;

    final buckets = aggregator(logs);
    final keys = buckets.keys.toList()..sort();
    if (keys.length < 2) return PredictionResult.empty;

    final xLiters = <double>[];
    final yLiters = <double>[];
    final xCost = <double>[];
    final yCost = <double>[];

    for (final key in keys) {
      final bucket = buckets[key]!;
      xLiters.add(key.toDouble());
      yLiters.add(bucket.liters);
      xCost.add(key.toDouble());
      yCost.add(bucket.cost);
    }

    final litersModel = LinearRegression()..fit(xLiters, yLiters);
    final costModel = LinearRegression()..fit(xCost, yCost);

    final today = now ?? DateTime.now();
    final start = isWeekly
        ? AnalysisServiceDateHelper.nextMonday(today)
        : DateTime(today.year, today.month + 1, 1);
    final nextIndex = isWeekly
        ? _weekIndex(start).toDouble()
        : _monthIndex(start).toDouble();
    final predictedLiters = litersModel
        .predict(nextIndex)
        .clamp(0.0, double.infinity)
        .toDouble();
    final predictedCost = costModel
        .predict(nextIndex)
        .clamp(0.0, double.infinity)
        .toDouble();
    final end = isWeekly
        ? start.add(const Duration(days: 6))
        : DateTime(start.year, start.month + 1, 0);

    return PredictionResult(
      predictedLiters: predictedLiters,
      predictedCost: predictedCost,
      trendSlope: costModel.slope,
      hasData: true,
      periodStart: start,
      periodEnd: end,
    );
  }

  static Map<int, _Agg> _weeklyAggregator(List<FuelLog> logs) {
    final buckets = <int, _Agg>{};
    for (final log in logs) {
      final weekIndex = _weekIndex(log.date);
      buckets.putIfAbsent(weekIndex, () => _Agg());
      buckets[weekIndex]!.add(log);
    }
    return buckets;
  }

  static Map<int, _Agg> _monthlyAggregator(List<FuelLog> logs) {
    final buckets = <int, _Agg>{};
    for (final log in logs) {
      final monthIndex = _monthIndex(log.date);
      buckets.putIfAbsent(monthIndex, () => _Agg());
      buckets[monthIndex]!.add(log);
    }
    return buckets;
  }

  static int _weekIndex(DateTime d) {
    final date = DateTime(d.year, d.month, d.day);
    final base = DateTime(2020, 1, 6);
    return date.difference(base).inDays ~/ 7;
  }

  static int _monthIndex(DateTime d) => d.year * 12 + (d.month - 1);
}

class AnalysisServiceDateHelper {
  AnalysisServiceDateHelper._();

  static DateTime nextMonday(DateTime from) {
    final date = DateTime(from.year, from.month, from.day);
    final daysUntilMonday = (8 - date.weekday) % 7;
    return date.add(Duration(days: daysUntilMonday == 0 ? 7 : daysUntilMonday));
  }
}

class _Agg {
  double liters = 0;
  double cost = 0;

  void add(FuelLog log) {
    liters += log.liters;
    cost += log.cost;
  }
}
