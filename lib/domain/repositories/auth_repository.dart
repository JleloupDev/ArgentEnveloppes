import 'package:argentenveloppes/domain/entities/user.dart';

/// Interface définissant les opérations d'authentification disponibles dans l'application.
/// 
/// Cette interface suit le principe d'inversion de dépendance du SOLID, permettant
/// aux couches supérieures de définir des abstractions dont dépendent les couches inférieures.
abstract class AuthRepository {
  /// Récupère l'utilisateur actuellement connecté ou null si personne n'est connecté
  Future<User?> getCurrentUser();

  /// Crée un flux qui émet un utilisateur à chaque changement d'état d'authentification
  Stream<User?> getAuthStateChanges();

  /// Authentifie un utilisateur avec Google
  Future<User> signInWithGoogle();

  /// Authentifie un utilisateur avec email et mot de passe
  Future<User> signInWithEmailAndPassword(String email, String password);

  /// Déconnecte l'utilisateur actuel
  Future<void> signOut();
}
