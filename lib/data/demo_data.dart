import '../models/fuel_log.dart';
import '../models/user_profile.dart';

class DemoData {
  DemoData._();

  static const String firstName = 'Paolo';
  static const String lastName = 'Reyes';
  static const String email = 'paolo.reyes@email.com';
  static const String vehicleName = 'Toyota Vios';
  static const String vehicleType = 'Sedan';
  static const String fuelType = 'Unleaded';
  static const String drivingStyle = 'Balanced';
  static const String location = 'Manila, PH';
  static const double monthlyBudget = 5000;

  static const List<String> vehicleTypes = [
    'Sedan',
    'Hatchback',
    'SUV',
    'Pickup',
    'Van',
    'Motorcycle',
  ];

  static const List<String> fuelTypes = [
    'Unleaded',
    'Premium',
    'Diesel',
    'Electric',
  ];

  static const List<String> drivingStyles = ['Eco', 'Balanced', 'Performance'];

  static const List<String> stations = [
    'Shell',
    'Petron',
    'Caltex',
    'Phoenix',
    'SeaOil',
    'Other',
  ];

  static const UserProfile profile = UserProfile(
    firstName: firstName,
    lastName: lastName,
    email: email,
    vehicleName: vehicleName,
    vehicleType: vehicleType,
    fuelType: fuelType,
    drivingStyle: drivingStyle,
    location: location,
    monthlyBudget: monthlyBudget,
  );

  static List<FuelLog> logs() => _seed();

  static List<FuelLog> _seed() {
    final raw = <List<Object>>[
      [0, 9.80, 63.40, 48210, 'Shell', 'Full tank before the week starts'],
      [4, 10.60, 63.25, 48030, 'Petron', ''],
      [8, 11.20, 63.10, 47820, 'Caltex', 'Slight traffic on EDSA'],
      [12, 9.40, 62.95, 47600, 'Shell', ''],
      [17, 12.10, 62.80, 47370, 'Petron', 'Weekend out of town'],
      [22, 10.20, 62.60, 47120, 'Phoenix', ''],
      [27, 9.90, 62.45, 46870, 'Shell', ''],
      [33, 11.50, 62.30, 46600, 'SeaOil', ''],
      [39, 10.40, 62.10, 46330, 'Petron', ''],
      [46, 9.60, 61.95, 46060, 'Caltex', ''],
      [53, 10.80, 61.80, 45790, 'Shell', ''],
      [61, 11.10, 61.60, 45520, 'Phoenix', ''],
    ];

    final now = DateTime.now();
    final list = <FuelLog>[];

    for (var i = 0; i < raw.length; i++) {
      final row = raw[i];
      final daysAgo = row[0] as int;
      final liters = row[1] as double;
      final price = row[2] as double;
      final odo = row[3] as int;
      final station = row[4] as String;
      final notes = row[5] as String;
      final date = now.subtract(Duration(days: daysAgo));
      list.add(
        FuelLog(
          id: 'log-${raw.length - i}',
          date: DateTime(date.year, date.month, date.day, 8 + (i % 8), 15),
          liters: liters,
          pricePerLiter: price,
          odometer: odo,
          station: station,
          notes: notes.isEmpty ? null : notes,
        ),
      );
    }

    for (var i = 0; i < list.length - 1; i++) {
      final newer = list[i];
      final older = list[i + 1];
      newer.kmDriven = (newer.odometer - older.odometer).toDouble();
    }
    if (list.isNotEmpty) list.last.kmDriven = 0;

    return list;
  }
}
