import '../data/demo_data.dart';
import '../models/fuel_log.dart';
import '../models/user_profile.dart';
import 'auth_repository.dart';
import 'fuel_repository.dart';

class DemoAuthRepository implements AuthRepository {
  AuthUser? _user;

  @override
  Future<AuthUser?> currentUser() async => _user;

  @override
  Future<AuthUser> signInAnonymously() async {
    final user = const AuthUser(id: 'demo-user', isAnonymous: true);
    _user = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    _user = null;
  }
}

class DemoFuelRepository implements FuelRepository {
  DemoFuelRepository({List<FuelLog>? logs, UserProfile? profile})
    : _logs = [for (final log in logs ?? DemoData.logs()) log.copyWith()],
      _profile = profile ?? DemoData.profile;

  List<FuelLog> _logs;
  UserProfile _profile;

  @override
  Future<List<FuelLog>> fetchLogs() async => [
    for (final log in _logs) log.copyWith(),
  ];

  @override
  Future<UserProfile> fetchProfile() async => _profile;

  @override
  Future<void> saveLog(FuelLog log) async {
    final index = _logs.indexWhere((item) => item.id == log.id);
    if (index < 0) {
      _logs = [log.copyWith(), ..._logs];
      return;
    }
    _logs = [..._logs]..[index] = log.copyWith();
  }

  @override
  Future<void> deleteLog(String id) async {
    _logs = _logs.where((log) => log.id != id).toList();
  }

  @override
  Future<void> replaceLogs(List<FuelLog> logs) async {
    _logs = [for (final log in logs) log.copyWith()];
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
  }
}
