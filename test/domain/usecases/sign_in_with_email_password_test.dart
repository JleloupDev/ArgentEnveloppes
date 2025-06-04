import 'package:flutter_test/flutter_test.dart';
import 'package:argentenveloppes/domain/entities/user.dart';
import 'package:mockito/mockito.dart';
import 'package:argentenveloppes/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {
  Future<User> signInWithEmailAndPassword(String email, String password) => super.noSuchMethod(
        Invocation.method(
          #signInWithEmailAndPassword,
          [email, password],
        ),
        returnValue: Future.value(User(uid: '1', email: email)),
        returnValueForMissingStub: Future.value(User(uid: '1', email: email)),
      );
}

void main() {
  group('SignInWithEmailPasswordUseCase', () {
    // Ce test a été supprimé car la connexion par email n'est plus supportée.
  });
}
