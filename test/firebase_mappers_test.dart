import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/models/fuel_log.dart';
import 'package:fuelwise/models/user_profile.dart';
import 'package:fuelwise/repositories/firebase/firebase_mappers.dart';

void main() {
  group('fuel log mapping', () {
    test('round-trips a complete log', () {
      final log = FuelLog(
        id: 'log-1',
        date: DateTime(2026, 10, 12, 8, 15),
        liters: 10.6,
        pricePerLiter: 63.25,
        odometer: 48030,
        station: 'Petron',
        notes: 'Full tank',
        kmDriven: 180,
      );

      final map = fuelLogToMap(log);
      expect(map['date'], isA<Timestamp>());
      final restored = fuelLogFromMap(log.id, map);

      expect(restored.id, 'log-1');
      expect(restored.date, log.date);
      expect(restored.liters, 10.6);
      expect(restored.pricePerLiter, 63.25);
      expect(restored.odometer, 48030);
      expect(restored.station, 'Petron');
      expect(restored.notes, 'Full tank');
      expect(restored.kmDriven, 180);
    });

    test('keeps null station and notes', () {
      final log = FuelLog(
        date: DateTime(2026, 10, 12),
        liters: 10,
        pricePerLiter: 60,
        odometer: 1000,
      );

      final restored = fuelLogFromMap('log-2', fuelLogToMap(log));
      expect(restored.station, isNull);
      expect(restored.notes, isNull);
    });

    test('coerces string and numeric values from Firestore', () {
      final restored = fuelLogFromMap('log-3', {
        'date': '2026-10-12T08:15:00.000',
        'liters': '11.2',
        'pricePerLiter': 63,
        'odometer': '47820',
        'kmDriven': '220.5',
      });

      expect(restored.date, DateTime(2026, 10, 12, 8, 15));
      expect(restored.liters, 11.2);
      expect(restored.pricePerLiter, 63.0);
      expect(restored.odometer, 47820);
      expect(restored.kmDriven, 220.5);
    });

    test('falls back to safe defaults for an empty document', () {
      final restored = fuelLogFromMap('log-4', {});
      expect(restored.liters, 0);
      expect(restored.pricePerLiter, 0);
      expect(restored.odometer, 0);
      expect(restored.kmDriven, 0);
    });
  });

  group('profile mapping', () {
    test('round-trips a profile', () {
      const profile = UserProfile(
        firstName: 'Paolo',
        lastName: 'Reyes',
        email: 'paolo.reyes@email.com',
        vehicleName: 'Toyota Vios',
        vehicleType: 'Sedan',
        fuelType: 'Unleaded',
        drivingStyle: 'Balanced',
        location: 'Manila, PH',
        monthlyBudget: 5000,
      );

      final restored = userProfileFromMap(userProfileToMap(profile));
      expect(restored.firstName, 'Paolo');
      expect(restored.fullName, 'Paolo Reyes');
      expect(restored.vehicleName, 'Toyota Vios');
      expect(restored.monthlyBudget, 5000);
      expect(restored.currencySymbol, '₱');
    });

    test('fills defaults for a missing document', () {
      final restored = userProfileFromMap({});
      expect(restored.firstName, '');
      expect(restored.monthlyBudget, 0);
      expect(restored.currencySymbol, '₱');
    });
  });
}
