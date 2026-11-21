import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/fuel_log.dart';
import '../../models/user_profile.dart';

Map<String, dynamic> fuelLogToMap(FuelLog log) {
  return {
    'date': Timestamp.fromDate(log.date),
    'liters': log.liters,
    'pricePerLiter': log.pricePerLiter,
    'odometer': log.odometer,
    'kmDriven': log.kmDriven,
    'station': log.station,
    'notes': log.notes,
  };
}

FuelLog fuelLogFromMap(String id, Map<String, dynamic> map) {
  return FuelLog(
    id: id,
    date: _dateFrom(map['date']) ?? DateTime.now(),
    liters: _doubleFrom(map['liters']),
    pricePerLiter: _doubleFrom(map['pricePerLiter']),
    odometer: _intFrom(map['odometer']),
    kmDriven: _doubleFrom(map['kmDriven']),
    station: map['station'] as String?,
    notes: map['notes'] as String?,
  );
}

Map<String, dynamic> userProfileToMap(UserProfile profile) {
  return {
    'firstName': profile.firstName,
    'lastName': profile.lastName,
    'email': profile.email,
    'vehicleName': profile.vehicleName,
    'vehicleType': profile.vehicleType,
    'fuelType': profile.fuelType,
    'drivingStyle': profile.drivingStyle,
    'location': profile.location,
    'monthlyBudget': profile.monthlyBudget,
    'currencySymbol': profile.currencySymbol,
  };
}

UserProfile userProfileFromMap(Map<String, dynamic> map) {
  return UserProfile(
    firstName: map['firstName'] as String? ?? '',
    lastName: map['lastName'] as String? ?? '',
    email: map['email'] as String? ?? '',
    vehicleName: map['vehicleName'] as String? ?? '',
    vehicleType: map['vehicleType'] as String? ?? '',
    fuelType: map['fuelType'] as String? ?? '',
    drivingStyle: map['drivingStyle'] as String? ?? '',
    location: map['location'] as String? ?? '',
    monthlyBudget: _doubleFrom(map['monthlyBudget']),
    currencySymbol: map['currencySymbol'] as String? ?? '₱',
  );
}

DateTime? _dateFrom(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

double _doubleFrom(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

int _intFrom(Object? value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
