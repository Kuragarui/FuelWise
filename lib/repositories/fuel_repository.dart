import '../models/fuel_log.dart';
import '../models/user_profile.dart';

abstract interface class FuelRepository {
  Future<List<FuelLog>> fetchLogs();

  Future<UserProfile> fetchProfile();

  Future<void> saveLog(FuelLog log);

  Future<void> deleteLog(String id);

  Future<void> replaceLogs(List<FuelLog> logs);

  Future<void> saveProfile(UserProfile profile);
}
