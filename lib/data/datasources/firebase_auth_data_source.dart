import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Source de données pour l'authentification Firebase
/// 
/// Cette classe gère les interactions directes avec Firebase Authentication API.
class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(
         clientId: kIsWeb ? const String.fromEnvironment('FIREBASE_WEB_CLIENT_ID') : null,
       );

  /// Obtient l'utilisateur Firebase actuellement connecté
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Crée un flux des changements d'état d'authentification
  Stream<User?> getAuthStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  /// Connecte un utilisateur avec Google
  Future<UserCredential> signInWithGoogle() async {
    // Déclenche le flux d'authentification Google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }

    // Obtient les détails d'authentification de la requête
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Crée un nouvel identifiant
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Connecte l'utilisateur avec Firebase en utilisant les identifiants
    return _firebaseAuth.signInWithCredential(credential);
  }

  /// Connecte un utilisateur avec email et mot de passe
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Déconnecte l'utilisateur actuel
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
