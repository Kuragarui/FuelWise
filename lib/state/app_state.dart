import 'dart:async';

import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../models/fuel_log.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';
import '../repositories/demo_repositories.dart';
import '../repositories/fuel_repository.dart';

class AppState extends ChangeNotifier {
  AppState({
    FuelRepository? repository,
    AuthRepository? authRepository,
    List<FuelLog>? initialLogs,
    UserProfile? initialProfile,
    this.firebaseEnabled = false,
  }) : _repository = repository ?? DemoFuelRepository(),
       _authRepository = authRepository ?? DemoAuthRepository() {
    _logs = [for (final log in initialLogs ?? DemoData.logs()) log.copyWith()];
    _profile = initialProfile ?? DemoData.profile;
    _recalculateMileage();
  }

  final FuelRepository _repository;
  final AuthRepository _authRepository;
  final bool firebaseEnabled;
  late List<FuelLog> _logs;
  late UserProfile _profile;
  bool _priceAlerts = true;
  bool _budgetAlerts = true;
  bool _weeklySummary = false;

  FuelRepository get repository => _repository;

  AuthRepository get authRepository => _authRepository;

  List<FuelLog> get logs => List.unmodifiable(_logs);

  UserProfile get profile => _profile;

  bool get priceAlerts => _priceAlerts;

  bool get budgetAlerts => _budgetAlerts;

  bool get weeklySummary => _weeklySummary;

  List<FuelLog> get recentLogs => _logs.take(3).toList();

  FuelLog? get latestLog => _logs.isEmpty ? null : _logs.first;

  double get averagePrice {
    if (_logs.isEmpty) return 0;
    final totalLiters = _logs.fold<double>(0, (sum, log) => sum + log.liters);
    if (totalLiters == 0) return 0;
    return _logs.fold<double>(0, (sum, log) => sum + log.cost) / totalLiters;
  }

  void addLog(FuelLog log) {
    final id = log.id.isEmpty
        ? 'log-${DateTime.now().microsecondsSinceEpoch}'
        : log.id;
    final saved = log.copyWith(id: id);
    _logs = [saved, ..._logs];
    _recalculateMileage();
    notifyListeners();
    _persist(_repository.saveLog(saved));
  }

  void deleteLog(String id) {
    if (id.isEmpty) return;
    final remaining = _logs.where((log) => log.id != id).toList();
    if (remaining.length == _logs.length) return;
    _logs = remaining;
    _recalculateMileage();
    notifyListeners();
    _persist(_repository.deleteLog(id));
  }

  void updateBudget(double budget) {
    _profile = _profile.copyWith(monthlyBudget: budget);
    notifyListeners();
    _persist(_repository.saveProfile(_profile));
  }

  void updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? vehicleName,
    String? vehicleType,
    String? fuelType,
    String? drivingStyle,
    String? location,
  }) {
    _profile = _profile.copyWith(
      firstName: firstName,
      lastName: lastName,
      email: email,
      vehicleName: vehicleName,
      vehicleType: vehicleType,
      fuelType: fuelType,
      drivingStyle: drivingStyle,
      location: location,
    );
    notifyListeners();
    _persist(_repository.saveProfile(_profile));
  }

  void setPriceAlerts(bool enabled) {
    _priceAlerts = enabled;
    notifyListeners();
  }

  void setBudgetAlerts(bool enabled) {
    _budgetAlerts = enabled;
    notifyListeners();
  }

  void setWeeklySummary(bool enabled) {
    _weeklySummary = enabled;
    notifyListeners();
  }

  void resetDemoData() {
    _logs = DemoData.logs();
    _profile = DemoData.profile;
    _priceAlerts = true;
    _budgetAlerts = true;
    _weeklySummary = false;
    _recalculateMileage();
    notifyListeners();
    _persist(_repository.replaceLogs(_logs));
    _persist(_repository.saveProfile(_profile));
  }

  void _persist(Future<void> operation) {
    unawaited(
      operation.catchError((Object error) {
        debugPrint('FuelWise persistence error: $error');
      }),
    );
  }

  void _recalculateMileage() {
    final sorted = [..._logs]..sort((a, b) => b.date.compareTo(a.date));
    _logs = sorted;

    for (var i = 0; i < _logs.length; i++) {
      final newer = _logs[i];
      if (i + 1 < _logs.length) {
        final older = _logs[i + 1];
        final km = newer.odometer - older.odometer;
        newer.kmDriven = km > 0 ? km.toDouble() : 0;
      } else {
        newer.kmDriven = 0;
      }
    }
  }
}
