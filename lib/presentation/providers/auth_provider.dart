import 'package:argentenveloppes/data/datasources/firebase_auth_data_source.dart';
import 'package:argentenveloppes/data/repositories_impl/auth_repository_impl.dart';
import 'package:argentenveloppes/domain/entities/user.dart';
import 'package:argentenveloppes/domain/repositories/auth_repository.dart';
import 'package:argentenveloppes/domain/usecases/get_auth_state.dart';
import 'package:argentenveloppes/domain/usecases/get_current_user.dart';
import 'package:argentenveloppes/domain/usecases/sign_in_with_google.dart';
import 'package:argentenveloppes/domain/usecases/sign_out.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Providers pour les dépendances
final firebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>((ref) {
  return firebase_auth.FirebaseAuth.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  // Récupérer le WEB_CLIENT_ID depuis les variables d'environnement Flutter
  // Ceci sera fourni via --dart-define lors du build/run
  const String webClientId = String.fromEnvironment('FIREBASE_WEB_CLIENT_ID');

  // Pour le web, il est crucial de passer le clientId
  if (kIsWeb) {
    if (webClientId.isEmpty) {
      // Si webClientId est vide (String.fromEnvironment retourne une chaîne vide si non trouvée)
      // On pourrait lancer une erreur ou un log plus critique ici.
      // Pour l'instant, on avertit et on laisse GoogleSignIn tenter de lire depuis index.html (ce qui échouera si la balise est supprimée)
      print('Attention: FIREBASE_WEB_CLIENT_ID n\'est pas défini via --dart-define. GoogleSignIn tentera de lire depuis index.html (ce qui ne fonctionnera pas si la balise meta est supprimée).');
      return GoogleSignIn(); // Tentera de lire la balise meta, ou échouera si absente.
    } else {
      print('Info: FIREBASE_WEB_CLIENT_ID défini via --dart-define et utilisé pour GoogleSignIn: $webClientId');
      return GoogleSignIn(
        clientId: webClientId,
        // scopes: ['email', 'profile'] // Ajoutez les scopes nécessaires
      );
    }
  } else {
    // Pour les autres plateformes (Android, iOS)
    return GoogleSignIn(
      // scopes: ['email', 'profile'] // Ajoutez les scopes nécessaires
    );
  }
});

final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final googleSignIn = ref.watch(googleSignInProvider);
  return FirebaseAuthDataSource(
    firebaseAuth: firebaseAuth, 
    googleSignIn: googleSignIn,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(firebaseAuthDataSourceProvider);
  return AuthRepositoryImpl(dataSource: dataSource);
});

// Providers pour les cas d'utilisation
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final getAuthStateUseCaseProvider = Provider<GetAuthStateUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetAuthStateUseCase(repository);
});

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithGoogleUseCase(repository);
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository);
});

// État d'authentification
final authStateProvider = StreamProvider<User?>((ref) {
  final getAuthStateUseCase = ref.watch(getAuthStateUseCaseProvider);
  return getAuthStateUseCase();
});

// Provider pour savoir si l'utilisateur est connecté
final isUserLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});

// Provider de l'utilisateur actuel
final currentUserProvider = FutureProvider<User?>((ref) {
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  return getCurrentUserUseCase();
});

// NotifierProvider pour gérer l'état et les actions d'authentification
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignOutUseCase _signOutUseCase;

  AuthNotifier({
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignOutUseCase signOutUseCase,
  }) : _signInWithGoogleUseCase = signInWithGoogleUseCase,
       _signOutUseCase = signOutUseCase,
       super(const AsyncValue.data(null));

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _signInWithGoogleUseCase();
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signOut() async {
    try {
      await _signOutUseCase();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final signInWithGoogleUseCase = ref.watch(signInWithGoogleUseCaseProvider);
  final signOutUseCase = ref.watch(signOutUseCaseProvider);
  
  return AuthNotifier(
    signInWithGoogleUseCase: signInWithGoogleUseCase,
    signOutUseCase: signOutUseCase,
  );
});
