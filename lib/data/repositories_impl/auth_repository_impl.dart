import 'package:argentenveloppes/data/datasources/firebase_auth_data_source.dart';
import 'package:argentenveloppes/data/models/user_model.dart';
import 'package:argentenveloppes/domain/entities/user.dart';
import 'package:argentenveloppes/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Implémentation du AuthRepository utilisant Firebase
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource dataSource;

  AuthRepositoryImpl({required this.dataSource});

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = dataSource.getCurrentUser();
    if (firebaseUser == null) {
      return null;
    }
    return UserModel.fromFirebaseUser(firebaseUser);
  }

  @override
  Stream<User?> getAuthStateChanges() {
    return dataSource.getAuthStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      return UserModel.fromFirebaseUser(firebaseUser);
    });
  }

  @override
  Future<User> signInWithGoogle() async {
    try {
      final userCredential = await dataSource.signInWithGoogle();
      if (userCredential.user == null) {
        throw firebase_auth.FirebaseAuthException(
          code: 'ERROR_USER_NOT_FOUND',
          message: 'User not found after Google sign in',
        );
      }
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  @override
  Future<void> signOut() {
    return dataSource.signOut();
  }

  // Transforme les erreurs spécifiques de Firebase en erreurs plus génériques ou explicites
  Exception _mapFirebaseAuthError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Aucun utilisateur trouvé avec cet email.');
      case 'wrong-password':
        return Exception('Mot de passe incorrect.');
      case 'email-already-in-use':
        return Exception('Cet email est déjà utilisé par un autre compte.');
      case 'weak-password':
        return Exception('Le mot de passe est trop faible.');
      case 'invalid-email':
        return Exception('Format d\'email invalide.');
      case 'operation-not-allowed':
        return Exception('Opération non autorisée.');
      case 'ERROR_ABORTED_BY_USER':
        return Exception('Connexion annulée par l\'utilisateur.');
      default:
        return Exception('Erreur d\'authentification: ${e.message}');
    }
  }
}
