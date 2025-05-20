import 'package:argentenveloppes/domain/entities/user.dart';
import 'package:argentenveloppes/domain/repositories/auth_repository.dart';

/// Cas d'utilisation pour récupérer l'utilisateur actuellement connecté.
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<User?> call() async {
    return repository.getCurrentUser();
  }
}
