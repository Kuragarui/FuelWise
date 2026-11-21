import 'package:flutter_test/flutter_test.dart';
import 'package:fuelwise/bootstrap.dart';
import 'package:fuelwise/data/demo_data.dart';
import 'package:fuelwise/models/fuel_log.dart';
import 'package:fuelwise/repositories/demo_repositories.dart';
import 'package:fuelwise/state/app_state.dart';

FuelLog newLog({String id = '', DateTime? date}) {
  return FuelLog(
    id: id,
    date: date ?? DateTime.now(),
    liters: 10,
    pricePerLiter: 60,
    odometer: 50000,
  );
}

void main() {
  group('DemoFuelRepository', () {
    test('seeds demo logs and profile', () async {
      final repository = DemoFuelRepository();
      expect((await repository.fetchLogs()).length, 12);
      expect((await repository.fetchProfile()).firstName, 'Paolo');
    });

    test('fetchLogs returns detached copies', () async {
      final repository = DemoFuelRepository();
      final first = (await repository.fetchLogs()).first;
      first.kmDriven = 999999;
      final again = (await repository.fetchLogs()).first;
      expect(again.kmDriven, isNot(999999));
    });

    test('saveLog inserts new refuels at the front', () async {
      final repository = DemoFuelRepository();
      await repository.saveLog(newLog(id: 'log-new'));
      final logs = await repository.fetchLogs();
      expect(logs.first.id, 'log-new');
      expect(logs.length, 13);
    });

    test('saveLog updates an existing refuel', () async {
      final repository = DemoFuelRepository();
      final existing = (await repository.fetchLogs()).first;
      await repository.saveLog(existing.copyWith(liters: 42));
      final logs = await repository.fetchLogs();
      expect(logs.length, 12);
      expect(logs.first.liters, 42);
    });

    test('deleteLog removes the refuel', () async {
      final repository = DemoFuelRepository();
      final existing = (await repository.fetchLogs()).first;
      await repository.deleteLog(existing.id);
      final logs = await repository.fetchLogs();
      expect(logs.length, 11);
      expect(logs.any((log) => log.id == existing.id), isFalse);
    });

    test('replaceLogs and saveProfile persist changes', () async {
      final repository = DemoFuelRepository();
      await repository.replaceLogs([newLog(id: 'only')]);
      await repository.saveProfile(
        DemoData.profile.copyWith(monthlyBudget: 7500),
      );
      expect((await repository.fetchLogs()).length, 1);
      expect((await repository.fetchProfile()).monthlyBudget, 7500);
    });
  });

  group('DemoAuthRepository', () {
    test('signs in anonymously and signs out', () async {
      final auth = DemoAuthRepository();
      expect(await auth.currentUser(), isNull);

      final user = await auth.signInAnonymously();
      expect(user.isAnonymous, isTrue);
      expect((await auth.currentUser())?.id, user.id);

      await auth.signOut();
      expect(await auth.currentUser(), isNull);
    });
  });

  group('AppState repositories', () {
    test('writes logs and profile through to the repository', () async {
      final repository = DemoFuelRepository();
      final state = AppState(repository: repository);

      state.addLog(newLog());
      state.updateBudget(8200);
      state.updateProfile(firstName: 'Maria');
      await Future<void>.delayed(Duration.zero);

      final storedLogs = await repository.fetchLogs();
      final storedProfile = await repository.fetchProfile();
      expect(storedLogs.length, 13);
      expect(storedProfile.monthlyBudget, 8200);
      expect(storedProfile.firstName, 'Maria');
    });

    test('deletes logs through to the repository', () async {
      final repository = DemoFuelRepository();
      final state = AppState(repository: repository);
      final removedId = state.logs.first.id;

      state.deleteLog(removedId);
      await Future<void>.delayed(Duration.zero);

      final storedLogs = await repository.fetchLogs();
      expect(storedLogs.length, 11);
      expect(storedLogs.any((log) => log.id == removedId), isFalse);
    });

    test('resetDemoData restores repository content', () async {
      final repository = DemoFuelRepository();
      final state = AppState(repository: repository);

      state.addLog(newLog());
      state.updateBudget(9999);
      await Future<void>.delayed(Duration.zero);

      state.resetDemoData();
      await Future<void>.delayed(Duration.zero);

      expect((await repository.fetchLogs()).length, 12);
      expect((await repository.fetchProfile()).monthlyBudget, 5000);
      expect(state.logs.length, 12);
    });

    test('accepts initial data and exposes its dependencies', () {
      final repository = DemoFuelRepository();
      final state = AppState(
        repository: repository,
        initialLogs: [newLog(id: 'seed')],
        initialProfile: DemoData.profile.copyWith(firstName: 'Alex'),
      );

      expect(state.logs.single.id, 'seed');
      expect(state.profile.firstName, 'Alex');
      expect(state.repository, same(repository));
      expect(state.authRepository, isNotNull);
      expect(state.firebaseEnabled, isFalse);
    });

    test('exposes the Firebase connection flag', () {
      final state = AppState(firebaseEnabled: true);
      expect(state.firebaseEnabled, isTrue);
    });
  });

  group('initializeAppDependencies', () {
    test('falls back to demo mode when Firebase is unavailable', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final dependencies = await initializeAppDependencies();

      expect(dependencies.firebaseEnabled, isFalse);
      expect(dependencies.fuelRepository, isNull);
      expect(dependencies.authRepository, isNull);
    });
  });
}
