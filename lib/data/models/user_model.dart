import 'package:argentenveloppes/domain/entities/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Modèle d'utilisateur qui étend l'entité de domaine User
/// 
/// Cette classe fait le pont entre l'entité du domaine et les données
/// provenant de Firebase Authentication.
class UserModel extends User {
  const UserModel({
    required String uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool isAnonymous = false,
    bool emailVerified = false,
  }) : super(
          uid: uid,
          email: email,
          displayName: displayName,
          photoURL: photoURL,
          isAnonymous: isAnonymous,
          emailVerified: emailVerified,
        );

  /// Crée un UserModel à partir d'un FirebaseUser
  factory UserModel.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      isAnonymous: firebaseUser.isAnonymous,
      emailVerified: firebaseUser.emailVerified,
    );
  }

  /// Convertit le modèle en entité User
  User toEntity() {
    return User(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      isAnonymous: isAnonymous,
      emailVerified: emailVerified,
    );
  }
}
