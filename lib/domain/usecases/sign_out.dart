import 'package:argentenveloppes/domain/repositories/auth_repository.dart';

/// Cas d'utilisation pour la déconnexion.
class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<void> call() async {
    return repository.signOut();
  }
}
