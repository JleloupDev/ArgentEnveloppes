# Guide d'Authentification Firebase pour ArgentEnveloppes

Ce document détaille la configuration et le fonctionnement de l'authentification Firebase (actuellement Google Sign-In) dans l'application ArgentEnveloppes, ainsi que les informations nécessaires pour la maintenance et les tests.

## 1. Aperçu de l'Architecture

L'authentification suit les principes de la Clean Architecture :

*   **Domain Layer**: Définit les contrats (abstractions) pour les fonctionnalités d'authentification (`AuthRepository`) et les cas d'utilisation (`SignInWithGoogleUseCase`).
*   **Data Layer**: Fournit les implémentations concrètes, interagissant avec Firebase Auth (`FirebaseAuthDataSource`, `AuthRepositoryImpl`).
*   **Presentation Layer**: Gère l'interface utilisateur (`LoginPage`) et la logique d'état (`AuthProvider`, `AuthNotifier`) en utilisant Riverpod.

## 2. Configuration de Firebase

### 2.1. Fichiers Clés

*   **`lib/firebase_options.dart`**: Contient la configuration Firebase spécifique à la plateforme (web, Android, iOS). Ce fichier est **généré dynamiquement** par des scripts en fonction de l'environnement. **Ne pas modifier manuellement pour les informations sensibles.**
*   **`index.html` (pour le Web)**:
    *   Inclut les SDK Firebase JavaScript :
        ```html
        <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js"></script>
        <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-auth-compat.js"></script>
        ```
    *   Contient la configuration Firebase pour l'initialisation web (remplacée par des placeholders qui sont injectés par des scripts) :
        ```html
        <script>
          const firebaseConfig = {
            apiKey: "YOUR_WEB_API_KEY", // Placeholder
            authDomain: "YOUR_AUTH_DOMAIN", // Placeholder
            // ... autres clés
          };
          firebase.initializeApp(firebaseConfig);
        </script>
        ```
    *   **Crucial pour Google Sign-In (Web)** : La balise meta pour l'ID client OAuth 2.0 :
        ```html
        <meta name="google-signin-client_id" content="YOUR_WEB_OAUTH_CLIENT_ID"> <!-- Placeholder -->
        ```
*   **`lib/main.dart`**: Initialise Firebase pour l'application Flutter :
    ```dart
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
    );
    ```

### 2.2. Gestion des Configurations par Environnement

Un script PowerShell est utilisé pour gérer les configurations Firebase pour différents environnements (développement, production, etc.).

*   **`apply_firebase_config.ps1`**: Script principal qui prend un paramètre `-Environment` (ex: `dev`, `prod`).
    *   Il lit les variables d'environnement à partir d'un fichier `.env.<environnement>.ps1` (ex: `.env.dev.ps1`).
    *   Il met à jour `lib/firebase_options.dart` et `index.html` avec les informations d'identification appropriées.
*   **Fichiers d'environnement (ex: `.env.dev.ps1`)**:
    *   Ces fichiers **ne doivent pas être versionnés s'ils contiennent des clés réelles pour des environnements autres que le développement local très basique**. Pour le développement, ils peuvent contenir des clés d'un projet Firebase de test.
    *   Ils définissent des variables PowerShell pour les clés Firebase (apiKey, authDomain, projectId, storageBucket, messagingSenderId, appId, et le `GoogleSignInClientIdWeb`).

### 2.3. Configuration CI/CD (GitHub Actions)

*   Le workflow `.github/workflows/deploy-flutter-web.yml` utilise les **Secrets GitHub** pour stocker les informations d'identification Firebase de production.
*   Pendant le build, ces secrets sont utilisés pour remplacer les placeholders dans `lib/firebase_options.dart` et `index.html` avant le déploiement sur GitHub Pages.

## 3. Flux d'Authentification Google Sign-In

1.  L'utilisateur clique sur le bouton "CONTINUER AVEC GOOGLE" sur la `LoginPage`.
2.  La méthode `_signInWithGoogle` dans `LoginPage` est appelée.
3.  Elle appelle `ref.read(authProvider.notifier).signInWithGoogle()`.
4.  `AuthNotifier.signInWithGoogle()` exécute `SignInWithGoogleUseCase`.
5.  `SignInWithGoogleUseCase` appelle `authRepository.signInWithGoogle()`.
6.  `AuthRepositoryImpl.signInWithGoogle()` appelle `firebaseAuthDataSource.signInWithGoogle()`.
7.  `FirebaseAuthDataSource.signInWithGoogle()` interagit avec `FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider())` (pour le web) ou des méthodes similaires pour d'autres plateformes, en utilisant `google_sign_in` si nécessaire.
8.  L'état de l'utilisateur est mis à jour via `authStateProvider` et `userProvider`.

## 4. Où Trouver les Informations d'Identification ?

*   **Console Firebase (`console.firebase.google.com`)**:
    *   Sélectionnez votre projet (ex: `argentenveloppes`).
    *   Allez dans "Paramètres du projet" (icône d'engrenage).
        *   **Onglet "Général"**:
            *   `ID du projet`
            *   `Clé API Web` (utilisée comme `apiKey`)
            *   `ID de l'application` (pour différentes plateformes)
        *   **Fichier de configuration GoogleService-Info.plist (iOS) et google-services.json (Android)**: Ces fichiers contiennent la configuration complète pour les plateformes mobiles. Le script `apply_firebase_config.ps1` s'attend à ce que les valeurs individuelles soient extraites de ces fichiers ou fournies directement.
    *   Allez dans "Authentication".
        *   **Onglet "Méthodes de connexion"**: Assurez-vous que "Google" est activé. Vous y trouverez aussi l' "ID client Web OAuth" et le "Code secret du client Web OAuth", mais c'est l'ID client de la console Google Cloud qui est généralement utilisé pour la balise meta.
        *   **Onglet "Domaines autorisés"**: Assurez-vous que les domaines de votre application (ex: `VOTRE_NOM_UTILISATEUR_GITHUB.github.io`, `localhost`) sont listés.

*   **Console Google Cloud (`console.cloud.google.com`)**:
    *   Assurez-vous que le bon projet (celui lié à votre projet Firebase) est sélectionné.
    *   Menu de navigation > "API et services" > "Identifiants".
    *   Sous **"ID clients OAuth 2.0"**, vous trouverez l'ID client de type **"Application Web"**. C'est cette valeur qui doit être utilisée pour la balise `<meta name="google-signin-client_id" content="VOTRE_ID_CLIENT_ICI">` dans `index.html`.
        *   Vérifiez que les "Origines JavaScript autorisées" et les "URI de redirection autorisés" sont correctement configurés pour votre application web (développement et production).

## 5. Exécuter l'Application Localement

1.  Assurez-vous que votre fichier `.env.dev.ps1` (ou l'équivalent pour votre environnement de test) est correctement rempli avec les informations d'identification d'un projet Firebase de test.
2.  Exécutez le script pour appliquer la configuration :
    ```powershell
    ./apply_firebase_config.ps1 -Environment dev
    ```
3.  Lancez l'application Flutter :
    ```bash
    flutter run -d chrome
    ```
    (ou un autre appareil/émulateur).

## 6. Tests

*   **Tests Unitaires**:
    *   Les cas d'utilisation (ex: `SignInWithGoogleUseCase`) doivent être testés en mockant le `AuthRepository`.
    *   Les repositories (ex: `AuthRepositoryImpl`) doivent être testés en mockant le `FirebaseAuthDataSource`.
    *   Les data sources (ex: `FirebaseAuthDataSource`) peuvent nécessiter de mocker `FirebaseAuth` et `GoogleSignIn`.
*   **Tests de Widgets**:
    *   Testez les widgets d'authentification (`LoginPage`) en fournissant des mocks pour les providers Riverpod (`authProvider`).
*   **Tests d'Intégration (Recommandé)**:
    *   Pour tester le flux complet avec une instance Firebase de test. Cela nécessite une configuration plus avancée.

**Important pour les tests**: Évitez d'utiliser des informations d'identification réelles dans les tests automatisés. Utilisez des mocks ou un projet Firebase dédié aux tests.

## 7. Déploiement

Le déploiement sur GitHub Pages est géré par le workflow GitHub Actions. Il injecte les secrets de production Firebase pendant le processus de build. Assurez-vous que les secrets GitHub (`FIREBASE_API_KEY_PROD`, `FIREBASE_AUTH_DOMAIN_PROD`, etc., et `GOOGLE_SIGN_IN_CLIENT_ID_PROD`) sont correctement configurés dans les paramètres de votre dépôt GitHub.
