import 'package:flutter/material.dart';

import 'bootstrap.dart';
import 'models/fuel_log.dart';
import 'models/user_profile.dart';
import 'repositories/auth_repository.dart';
import 'repositories/fuel_repository.dart';
import 'screens/fuel_budget_screen.dart';
import 'screens/log_refuel_screen.dart';
import 'screens/main_shell.dart';
import 'screens/plan_next_week_screen.dart';
import 'screens/refuel_history_screen.dart';
import 'screens/welcome_screen.dart';
import 'state/app_scope.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await initializeAppDependencies();
  runApp(
    FuelWiseApp(
      fuelRepository: dependencies.fuelRepository,
      authRepository: dependencies.authRepository,
      initialLogs: dependencies.initialLogs,
      initialProfile: dependencies.initialProfile,
      firebaseEnabled: dependencies.firebaseEnabled,
    ),
  );
}

class FuelWiseApp extends StatefulWidget {
  final FuelRepository? fuelRepository;
  final AuthRepository? authRepository;
  final List<FuelLog>? initialLogs;
  final UserProfile? initialProfile;
  final bool firebaseEnabled;

  const FuelWiseApp({
    super.key,
    this.fuelRepository,
    this.authRepository,
    this.initialLogs,
    this.initialProfile,
    this.firebaseEnabled = false,
  });

  @override
  State<FuelWiseApp> createState() => _FuelWiseAppState();
}

class _FuelWiseAppState extends State<FuelWiseApp> {
  late final AppState _state = AppState(
    repository: widget.fuelRepository,
    authRepository: widget.authRepository,
    initialLogs: widget.initialLogs,
    initialProfile: widget.initialProfile,
    firebaseEnabled: widget.firebaseEnabled,
  );

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp(
        title: 'FuelWise',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const WelcomeScreen(),
        routes: {
          MainShell.routeName: (_) => const MainShell(),
          LogRefuelScreen.routeName: (_) => const LogRefuelScreen(),
          RefuelHistoryScreen.routeName: (_) => const RefuelHistoryScreen(),
          PlanNextWeekScreen.routeName: (_) => const PlanNextWeekScreen(),
          FuelBudgetScreen.routeName: (_) => const FuelBudgetScreen(),
        },
      ),
    );
  }
}
