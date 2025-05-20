/// Entité User selon les principes du Clean Architecture.
/// 
/// Cette entité représente un utilisateur authentifié dans l'application.
/// Elle ne contient que les données essentielles et ne dépend d'aucune
/// infrastructure externe (comme Firebase).
class User {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isAnonymous;
  final bool emailVerified;

  const User({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.isAnonymous = false,
    this.emailVerified = false,
  });

  /// Crée une copie de l'utilisateur avec les champs spécifiés modifiés
  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? isAnonymous,
    bool? emailVerified,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}
