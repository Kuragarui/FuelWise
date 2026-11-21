class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String vehicleName;
  final String vehicleType;
  final String fuelType;
  final String drivingStyle;
  final String location;
  final double monthlyBudget;
  final String currencySymbol;

  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.vehicleName,
    required this.vehicleType,
    required this.fuelType,
    required this.drivingStyle,
    required this.location,
    required this.monthlyBudget,
    this.currencySymbol = '₱',
  });

  String get fullName => '$firstName $lastName';

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? vehicleName,
    String? vehicleType,
    String? fuelType,
    String? drivingStyle,
    String? location,
    double? monthlyBudget,
    String? currencySymbol,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleType: vehicleType ?? this.vehicleType,
      fuelType: fuelType ?? this.fuelType,
      drivingStyle: drivingStyle ?? this.drivingStyle,
      location: location ?? this.location,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }
}
