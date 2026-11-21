import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/models/fuel_log.dart';
import 'package:fuelwise/state/app_state.dart';

void main() {
  group('AppState', () {
    test('seeds demo persona and logs', () {
      final state = AppState();
      expect(state.profile.firstName, 'Paolo');
      expect(state.profile.monthlyBudget, 5000);
      expect(state.logs, isNotEmpty);
      expect(state.logs.last.kmDriven, 0);
    });

    test('adds a log and keeps logs sorted newest first', () {
      final state = AppState();
      final initialCount = state.logs.length;
      state.addLog(
        FuelLog(
          date: DateTime.now(),
          liters: 12,
          pricePerLiter: 64,
          odometer: 60000,
          station: 'Shell',
        ),
      );
      expect(state.logs.length, initialCount + 1);
      expect(state.logs.first.station, 'Shell');
      expect(state.logs.first.id, isNotEmpty);
    });

    test('recalculates mileage after adding a newer log', () {
      final state = AppState();
      final previousOdometer = state.logs.first.odometer;
      state.addLog(
        FuelLog(
          date: DateTime.now().add(const Duration(days: 1)),
          liters: 10,
          pricePerLiter: 64,
          odometer: previousOdometer + 300,
        ),
      );
      expect(state.logs.first.kmDriven, 300);
    });

    test('deletes a log and recalculates remaining mileage', () {
      final state = AppState(
        initialLogs: [
          FuelLog(
            id: 'older',
            date: DateTime(2026, 10, 1),
            liters: 10,
            pricePerLiter: 60,
            odometer: 1000,
          ),
          FuelLog(
            id: 'middle',
            date: DateTime(2026, 10, 2),
            liters: 10,
            pricePerLiter: 60,
            odometer: 1200,
          ),
          FuelLog(
            id: 'newer',
            date: DateTime(2026, 10, 3),
            liters: 10,
            pricePerLiter: 60,
            odometer: 1500,
          ),
        ],
      );
      expect(state.logs.first.kmDriven, 300);

      state.deleteLog('middle');

      expect(state.logs.length, 2);
      expect(state.logs.first.id, 'newer');
      expect(state.logs.first.kmDriven, 500);
      expect(state.logs.last.id, 'older');
      expect(state.logs.last.kmDriven, 0);
    });

    test('updates budget and profile', () {
      final state = AppState();
      state.updateBudget(6500);
      expect(state.profile.monthlyBudget, 6500);

      state.updateProfile(firstName: 'Maria', vehicleName: 'Honda City');
      expect(state.profile.firstName, 'Maria');
      expect(state.profile.vehicleName, 'Honda City');
    });

    test('notifies listeners on changes', () {
      final state = AppState();
      var notified = 0;
      state.addListener(() => notified++);

      state.updateBudget(4000);
      state.setPriceAlerts(false);
      state.setBudgetAlerts(false);
      state.setWeeklySummary(true);

      expect(notified, 4);
      expect(state.priceAlerts, isFalse);
      expect(state.budgetAlerts, isFalse);
      expect(state.weeklySummary, isTrue);
    });

    test('resetDemoData restores seed values', () {
      final state = AppState();
      final initialCount = state.logs.length;
      state.addLog(
        FuelLog(
          date: DateTime.now(),
          liters: 10,
          pricePerLiter: 60,
          odometer: 70000,
        ),
      );
      state.updateBudget(9000);
      state.resetDemoData();

      expect(state.logs.length, initialCount);
      expect(state.profile.monthlyBudget, 5000);
      expect(state.priceAlerts, isTrue);
    });
  });
}
