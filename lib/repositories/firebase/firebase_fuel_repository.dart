import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/demo_data.dart';
import '../../models/fuel_log.dart';
import '../../models/user_profile.dart';
import '../fuel_repository.dart';
import 'firebase_mappers.dart';

class FirebaseFuelRepository implements FuelRepository {
  FirebaseFuelRepository(this._userId, {FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final String _userId;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> get _profileRef =>
      _firestore.collection('users').doc(_userId);

  CollectionReference<Map<String, dynamic>> get _logsRef =>
      _profileRef.collection('logs');

  @override
  Future<List<FuelLog>> fetchLogs() async {
    final snapshot = await _logsRef.orderBy('date', descending: true).get();
    return [
      for (final doc in snapshot.docs) fuelLogFromMap(doc.id, doc.data()),
    ];
  }

  @override
  Future<UserProfile> fetchProfile() async {
    final snapshot = await _profileRef.get();
    final data = snapshot.data();
    if (data == null) return DemoData.profile;
    return userProfileFromMap(data);
  }

  @override
  Future<void> saveLog(FuelLog log) async {
    final id = log.id.isEmpty ? _logsRef.doc().id : log.id;
    await _logsRef.doc(id).set(fuelLogToMap(log.copyWith(id: id)));
  }

  @override
  Future<void> deleteLog(String id) async {
    if (id.isEmpty) return;
    await _logsRef.doc(id).delete();
  }

  @override
  Future<void> replaceLogs(List<FuelLog> logs) async {
    final existing = await _logsRef.get();
    final batch = _firestore.batch();
    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }
    for (final log in logs) {
      final id = log.id.isEmpty ? _logsRef.doc().id : log.id;
      batch.set(_logsRef.doc(id), fuelLogToMap(log.copyWith(id: id)));
    }
    await batch.commit();
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _profileRef.set(userProfileToMap(profile));
  }
}
