class FuelLog {
  final String id;
  final DateTime date;
  final double liters;
  final double pricePerLiter;
  final int odometer;
  final String? station;
  final String? notes;
  double kmDriven;

  FuelLog({
    required this.date,
    required this.liters,
    required this.pricePerLiter,
    required this.odometer,
    this.id = '',
    this.station,
    this.notes,
    this.kmDriven = 0,
  });

  double get cost => liters * pricePerLiter;

  double get lPer100km => kmDriven > 0 ? (liters / kmDriven) * 100 : 0;

  double get kmPerL => liters > 0 ? kmDriven / liters : 0;

  FuelLog copyWith({
    String? id,
    DateTime? date,
    double? liters,
    double? pricePerLiter,
    int? odometer,
    String? station,
    String? notes,
    double? kmDriven,
  }) {
    return FuelLog(
      id: id ?? this.id,
      date: date ?? this.date,
      liters: liters ?? this.liters,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      odometer: odometer ?? this.odometer,
      station: station ?? this.station,
      notes: notes ?? this.notes,
      kmDriven: kmDriven ?? this.kmDriven,
    );
  }
}
