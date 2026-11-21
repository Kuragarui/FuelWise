class AuthUser {
  final String id;
  final bool isAnonymous;

  const AuthUser({required this.id, this.isAnonymous = false});
}

abstract interface class AuthRepository {
  Future<AuthUser?> currentUser();

  Future<AuthUser> signInAnonymously();

  Future<void> signOut();
}
