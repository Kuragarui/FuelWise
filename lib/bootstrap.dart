import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'data/demo_data.dart';
import 'firebase_options.dart';
import 'models/fuel_log.dart';
import 'models/user_profile.dart';
import 'repositories/auth_repository.dart';
import 'repositories/firebase/firebase_auth_repository.dart';
import 'repositories/firebase/firebase_fuel_repository.dart';
import 'repositories/fuel_repository.dart';

class AppDependencies {
  final FuelRepository? fuelRepository;
  final AuthRepository? authRepository;
  final List<FuelLog>? initialLogs;
  final UserProfile? initialProfile;
  final bool firebaseEnabled;

  const AppDependencies({
    this.fuelRepository,
    this.authRepository,
    this.initialLogs,
    this.initialProfile,
    this.firebaseEnabled = false,
  });
}

Future<AppDependencies> initializeAppDependencies() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final authRepository = FirebaseAuthRepository();
    final user =
        await authRepository.currentUser() ??
        await authRepository.signInAnonymously();
    final fuelRepository = FirebaseFuelRepository(user.id);

    var logs = await fuelRepository.fetchLogs();
    if (logs.isEmpty) {
      await fuelRepository.replaceLogs(DemoData.logs());
      logs = await fuelRepository.fetchLogs();
    }
    final profile = await fuelRepository.fetchProfile();

    return AppDependencies(
      fuelRepository: fuelRepository,
      authRepository: authRepository,
      initialLogs: logs,
      initialProfile: profile,
      firebaseEnabled: true,
    );
  } catch (error) {
    debugPrint('Firebase unavailable, running in demo mode: $error');
    return const AppDependencies();
  }
}
