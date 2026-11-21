class TripEstimate {
  final double distanceKm;
  final double liters;
  final double cost;
  final bool roundTrip;

  const TripEstimate({
    required this.distanceKm,
    required this.liters,
    required this.cost,
    required this.roundTrip,
  });

  static const empty = TripEstimate(
    distanceKm: 0,
    liters: 0,
    cost: 0,
    roundTrip: false,
  );
}

class TripService {
  TripService._();

  static TripEstimate estimate({
    required double oneWayKm,
    required bool roundTrip,
    required double kmPerLiter,
    required double pricePerLiter,
  }) {
    if (oneWayKm <= 0) return TripEstimate.empty;
    final distance = roundTrip ? oneWayKm * 2 : oneWayKm;
    final liters = kmPerLiter > 0 ? distance / kmPerLiter : 0.0;
    return TripEstimate(
      distanceKm: distance,
      liters: liters,
      cost: liters * pricePerLiter,
      roundTrip: roundTrip,
    );
  }
}
