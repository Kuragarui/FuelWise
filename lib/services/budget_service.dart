import '../models/fuel_log.dart';

class BudgetStatus {
  final double budget;
  final double spent;
  final double remaining;
  final double projected;
  final double progress;
  final bool hasBudget;

  const BudgetStatus({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.projected,
    required this.progress,
    required this.hasBudget,
  });

  static const empty = BudgetStatus(
    budget: 0,
    spent: 0,
    remaining: 0,
    projected: 0,
    progress: 0,
    hasBudget: false,
  );

  bool get isOverspent => remaining < 0;

  bool get isNearLimit => hasBudget && progress >= 0.9 && !isOverspent;

  double get remainingPercent =>
      hasBudget ? (remaining / budget).clamp(0, 1).toDouble() : 0;
}

class BudgetService {
  BudgetService._();

  static BudgetStatus status({
    required List<FuelLog> logs,
    required double budget,
    required double projectedSpend,
    DateTime? now,
  }) {
    if (budget <= 0) return BudgetStatus.empty;
    final today = now ?? DateTime.now();
    final spent = monthSpent(logs, now: today);
    final projected = spent + (projectedSpend > 0 ? projectedSpend : 0);
    final remaining = budget - spent;
    return BudgetStatus(
      budget: budget,
      spent: spent,
      remaining: remaining,
      projected: projected,
      progress: (spent / budget).clamp(0, 1).toDouble(),
      hasBudget: true,
    );
  }

  static double monthSpent(List<FuelLog> logs, {DateTime? now}) {
    final today = now ?? DateTime.now();
    return logs
        .where(
          (log) => log.date.year == today.year && log.date.month == today.month,
        )
        .fold<double>(0, (sum, log) => sum + log.cost);
  }

  static double projectedMonthEnd({
    required List<FuelLog> logs,
    required double weeklyForecast,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final spent = monthSpent(logs, now: today);
    if (weeklyForecast <= 0) return spent;
    final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
    final daysRemaining = daysInMonth - today.day;
    return spent + weeklyForecast * (daysRemaining / 7);
  }

  static double averageMonthlySpend(List<FuelLog> logs, {int months = 3}) {
    if (logs.isEmpty) return 0;
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month - (months - 1));
    final totals = <String, double>{};
    for (final log in logs) {
      if (log.date.isBefore(cutoff)) continue;
      final key = '${log.date.year}-${log.date.month}';
      totals[key] = (totals[key] ?? 0) + log.cost;
    }
    if (totals.isEmpty) return 0;
    return totals.values.reduce((a, b) => a + b) / totals.length;
  }
}
