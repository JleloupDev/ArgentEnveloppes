import 'package:argentenveloppes/domain/entities/user.dart';
import 'package:argentenveloppes/domain/repositories/auth_repository.dart';

/// Cas d'utilisation pour la connexion avec email et mot de passe.
class SignInWithEmailPasswordUseCase {
  final AuthRepository repository;

  SignInWithEmailPasswordUseCase(this.repository);

  Future<User> call(String email, String password) async {
    return repository.signInWithEmailAndPassword(email, password);
  }
}
