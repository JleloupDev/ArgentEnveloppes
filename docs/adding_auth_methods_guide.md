# Guide pour Ajouter de Nouvelles Méthodes d'Authentification Firebase

Ce guide explique comment ajouter de nouvelles méthodes d'authentification (par exemple, email/mot de passe, téléphone, etc.) à l'application ArgentEnveloppes, en respectant la Clean Architecture établie.

## 1. Prérequis

1.  **Activer la Méthode dans la Console Firebase**:
    *   Allez sur la [Console Firebase](https://console.firebase.google.com/).
    *   Sélectionnez votre projet.
    *   Allez dans "Authentication" > "Méthodes de connexion".
    *   Activez et configurez la nouvelle méthode souhaitée (ex: "E-mail/Mot de passe").

2.  **Dépendances (si nécessaire)**:
    *   Vérifiez si la nouvelle méthode nécessite des packages Flutter supplémentaires. Par exemple, l'authentification par téléphone pourrait nécessiter `firebase_phone_auth_handler` ou une gestion spécifique. Ajoutez-les à `pubspec.yaml` et exécutez `flutter pub get`.

3.  **Configuration `index.html` (pour le Web, si applicable)**:
    *   Certaines méthodes d'authentification web peuvent nécessiter des SDK JavaScript Firebase supplémentaires ou des configurations spécifiques dans `index.html`. Consultez la documentation Firebase.

## 2. Implémentation selon la Clean Architecture

### Étape 1: Domain Layer

*   **Mettre à jour `AuthRepository` (`lib/domain/repositories/auth_repository.dart`)**:
    Ajoutez de nouvelles méthodes abstraites pour les nouvelles fonctionnalités.
    Exemple pour l'authentification par email/mot de passe :
    ```dart
    abstract class AuthRepository {
      // ... méthodes existantes (signInWithGoogle, signOut, authStateChanges, getCurrentUser) ...

      Future<UserCredential?> signInWithEmailPassword(String email, String password);
      Future<UserCredential?> signUpWithEmailPassword(String email, String password);
      Future<void> sendPasswordResetEmail(String email);
    }
    ```

*   **Créer de Nouveaux Cas d'Utilisation (`lib/domain/usecases/`)**:
    Créez des fichiers distincts pour chaque nouveau cas d'utilisation.
    Exemple : `sign_in_with_email_password_use_case.dart`
    ```dart
    import 'package:firebase_auth/firebase_auth.dart';
    import 'package:argentenveloppes/domain/repositories/auth_repository.dart';

    class SignInWithEmailPasswordUseCase {
      final AuthRepository _repository;

      SignInWithEmailPasswordUseCase(this._repository);

      Future<UserCredential?> call(String email, String password) {
        return _repository.signInWithEmailPassword(email, password);
      }
    }
    ```
    Créez des cas d'utilisation similaires pour l'inscription, la réinitialisation de mot de passe, etc.

### Étape 2: Data Layer

*   **Mettre à jour `FirebaseAuthDataSource` (`lib/data/datasources/firebase_auth_data_source.dart`)**:
    Ajoutez les implémentations concrètes qui interagissent directement avec `FirebaseAuth.instance`.
    Exemple pour `signInWithEmailPassword`:
    ```dart
    class FirebaseAuthDataSource {
      final FirebaseAuth _firebaseAuth;
      // ... constructeur et méthodes existantes ...

      Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
        try {
          return await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
        } on FirebaseAuthException catch (e) {
          // Gérer les erreurs spécifiques (e.g., user-not-found, wrong-password)
          print('FirebaseAuthException: ${e.code} - ${e.message}');
          throw; // ou retourner une exception personnalisée
        }
      }

      // Implémentez signUpWithEmailPassword, sendPasswordResetEmail, etc.
    }
    ```

*   **Mettre à jour `AuthRepositoryImpl` (`lib/data/repositories_impl/auth_repository_impl.dart`)**:
    Implémentez les nouvelles méthodes de l'interface `AuthRepository` en appelant les méthodes correspondantes du `FirebaseAuthDataSource`.
    Exemple pour `signInWithEmailPassword`:
    ```dart
    class AuthRepositoryImpl implements AuthRepository {
      final FirebaseAuthDataSource _firebaseAuthDataSource;
      // ... constructeur et méthodes existantes ...

      @override
      Future<UserCredential?> signInWithEmailPassword(String email, String password) {
        return _firebaseAuthDataSource.signInWithEmailPassword(email, password);
      }

      // Implémentez les autres nouvelles méthodes
    }
    ```

### Étape 3: Presentation Layer (Providers - Riverpod)

*   **Mettre à jour `AuthNotifier` (dans `lib/presentation/providers/auth_provider.dart`)**:
    1.  Injectez les nouveaux cas d'utilisation dans le `AuthNotifier` via son constructeur.
    2.  Ajoutez de nouvelles méthodes dans `AuthNotifier` pour appeler ces cas d'utilisation et gérer l'état (chargement, succès, erreur).

    Exemple :
    ```dart
    // Dans auth_provider.dart

    // ... (autres providers pour les nouveaux use cases) ...
    final signInWithEmailPasswordUseCaseProvider = Provider<SignInWithEmailPasswordUseCase>((ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      return SignInWithEmailPasswordUseCase(authRepository);
    });

    class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
      final Ref _ref;
      // ... (use cases existants) ...
      final SignInWithEmailPasswordUseCase _signInWithEmailPasswordUseCase;
      // ... (autres nouveaux use cases) ...

      AuthNotifier(this._ref, /* ... existing use cases ... */ this._signInWithEmailPasswordUseCase)
          : super(const AsyncLoading()) {
        // ... (initialisation existante) ...
      }

      // ... (méthodes existantes : signInWithGoogle, signOut) ...

      Future<void> signInWithEmailPassword(String email, String password) async {
        state = const AsyncLoading();
        try {
          final userCredential = await _signInWithEmailPasswordUseCase(email, password);
          state = AsyncData(userCredential?.user);
        } catch (e, st) {
          state = AsyncError(e, st);
        }
      }

      // Ajoutez des méthodes pour signUp, sendPasswordReset, etc.
    }
    ```
    N'oubliez pas de mettre à jour l'instanciation de `AuthNotifier` dans le `authProvider` pour inclure les nouveaux cas d'utilisation.

### Étape 4: Presentation Layer (UI)

*   **Créer/Modifier les Pages/Widgets**:
    *   Si nécessaire, créez de nouvelles pages (ex: `SignupPage`, `ForgotPasswordPage`).
    *   Modifiez les pages existantes (ex: `LoginPage`) pour ajouter les nouveaux champs de saisie (email, mot de passe) et les boutons correspondants.
    *   Utilisez `ConsumerWidget` ou `ConsumerStatefulWidget` pour interagir avec `authProvider`.
    *   Appelez les méthodes appropriées du `AuthNotifier` (ex: `ref.read(authProvider.notifier).signInWithEmailPassword(email, password);`).
    *   Gérez l'état de chargement et les erreurs affichées à l'utilisateur.

    Exemple (extrait simplifié pour un bouton de connexion par email) :
    ```dart
    // Dans LoginPage ou une page similaire
    ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          // Supposons que _emailController et _passwordController existent
          final email = _emailController.text;
          final password = _passwordController.text;
          await ref.read(authProvider.notifier).signInWithEmailPassword(email, password);
          // La redirection sera gérée par l'observation de authStateProvider ou userProvider
        }
      },
      child: const Text('Se connecter par Email'),
    ),
    ```

## 3. Configuration Spécifique à la Méthode

*   **Mettre à jour `apply_firebase_config.ps1` et les fichiers `.env`**:
    Si la nouvelle méthode d'authentification nécessite des clés de configuration spécifiques (par exemple, des clés API spéciales pour des services tiers liés à l'authentification), ajoutez-les aux fichiers d'environnement (`.env.dev.ps1`, etc.) et modifiez le script `apply_firebase_config.ps1` pour les injecter aux bons endroits (probablement `lib/firebase_options.dart` ou `index.html`).

## 4. Tests

*   **Tests Unitaires**:
    *   Écrivez des tests pour chaque nouveau cas d'utilisation, en mockant le `AuthRepository`.
    *   Mettez à jour les tests pour `AuthRepositoryImpl` et `FirebaseAuthDataSource` pour couvrir les nouvelles méthodes.
*   **Tests de Widgets**:
    *   Créez des tests pour les nouveaux écrans ou les modifications d'écrans d'authentification. Mockez `authProvider` pour simuler différents états (chargement, succès, erreur, utilisateur connecté/déconnecté).
*   **Tests d'Intégration**:
    *   Envisagez des tests d'intégration pour vérifier le flux complet de la nouvelle méthode d'authentification avec un projet Firebase de test.

## 5. Considérations Supplémentaires

*   **Gestion des Erreurs**: Fournissez des messages d'erreur clairs et localisés à l'utilisateur pour les différents scénarios d'échec (ex: utilisateur non trouvé, mot de passe incorrect, email déjà utilisé).
*   **Validation des Entrées**: Validez les entrées utilisateur (format de l'email, complexité du mot de passe) côté client avant d'appeler Firebase.
*   **Flux Utilisateur**: Pensez au flux utilisateur complet, y compris la navigation après une connexion/inscription réussie ou un échec.
*   **Sécurité**: Suivez les meilleures pratiques de sécurité pour la gestion des mots de passe et des sessions utilisateur.

En suivant ces étapes, vous pourrez intégrer de nouvelles méthodes d'authentification de manière structurée et maintenable.
