import 'package:argentenveloppes/domain/entities/user.dart';
import 'package:argentenveloppes/domain/repositories/auth_repository.dart';

/// Cas d'utilisation pour la connexion avec Google.
class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<User> call() async {
    return repository.signInWithGoogle();
  }
}
