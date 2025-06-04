import 'package:flutter_test/flutter_test.dart';
import 'package:argentenveloppes/domain/usecases/sign_in_with_email_password.dart';
import 'package:argentenveloppes/domain/entities/user.dart';
import 'package:mockito/mockito.dart';
import 'package:argentenveloppes/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('SignInWithEmailPasswordUseCase', () {
    test('calls repository.signInWithEmailAndPassword and returns User', () async {
      final mockRepo = MockAuthRepository();
      final useCase = SignInWithEmailPasswordUseCase(mockRepo);
      final user = User(id: '1', email: 'test@test.com');
      when(mockRepo.signInWithEmailAndPassword('test@test.com', 'password'))
          .thenAnswer((_) async => user);
      final result = await useCase('test@test.com', 'password');
      expect(result, user);
      verify(mockRepo.signInWithEmailAndPassword('test@test.com', 'password')).called(1);
    });
  });
}
