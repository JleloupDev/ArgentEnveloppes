import 'package:argentenveloppes/domain/entities/user.dart';
import 'package:argentenveloppes/domain/repositories/auth_repository.dart';

/// Cas d'utilisation pour la création d'un compte avec email et mot de passe.
class SignUpWithEmailPasswordUseCase {
  final AuthRepository repository;

  SignUpWithEmailPasswordUseCase(this.repository);

  Future<User> call(String email, String password) async {
    return repository.signUpWithEmailAndPassword(email, password);
  }
}
