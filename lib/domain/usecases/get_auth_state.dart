import 'package:argentenveloppes/domain/entities/user.dart';
import 'package:argentenveloppes/domain/repositories/auth_repository.dart';

/// Cas d'utilisation pour obtenir un flux des changements d'état d'authentification.
class GetAuthStateUseCase {
  final AuthRepository repository;

  GetAuthStateUseCase(this.repository);

  Stream<User?> call() {
    return repository.getAuthStateChanges();
  }
}
