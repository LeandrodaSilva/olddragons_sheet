import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ods/services/auth_service.dart';

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  final FakeUser _user;
  bool signOutCalled = false;

  FakeFirebaseAuth({String uid = 'test-uid'}) : _user = FakeUser(uid: uid);

  @override
  User? get currentUser => _user;

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }

  @override
  Stream<User?> authStateChanges() => Stream.value(_user);
}

class FakeUser extends Fake implements User {
  @override
  final String uid;

  FakeUser({required this.uid});
}

void main() {
  group('AuthService', () {
    late FakeFirebaseAuth fakeAuth;
    late AuthService authService;

    setUp(() {
      fakeAuth = FakeFirebaseAuth(uid: 'user-123');
      authService = AuthService(auth: fakeAuth);
    });

    test('currentUser returns the user from FirebaseAuth', () {
      final user = authService.currentUser;
      expect(user, isNotNull);
      expect(user!.uid, 'user-123');
    });

    test('signOut delegates to FirebaseAuth.signOut', () async {
      await authService.signOut();
      expect(fakeAuth.signOutCalled, isTrue);
    });

    test('authStateChanges delegates to FirebaseAuth.authStateChanges',
        () async {
      final user = await authService.authStateChanges().first;
      expect(user, isNotNull);
      expect(user!.uid, 'user-123');
    });
  });
}
