import 'package:argentenveloppes/domain/repositories/auth_repository.dart';

/// Cas d'utilisation pour l'envoi d'un email de réinitialisation de mot de passe.
class SendPasswordResetEmailUseCase {
  final AuthRepository repository;

  SendPasswordResetEmailUseCase(this.repository);

  Future<void> call(String email) async {
    return repository.sendPasswordResetEmail(email);
  }
}
