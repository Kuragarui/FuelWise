import 'package:firebase_auth/firebase_auth.dart';

import '../auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Future<AuthUser?> currentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return AuthUser(id: user.uid, isAnonymous: user.isAnonymous);
  }

  @override
  Future<AuthUser> signInAnonymously() async {
    final credential = await _auth.signInAnonymously();
    final user = credential.user!;
    return AuthUser(id: user.uid, isAnonymous: user.isAnonymous);
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
