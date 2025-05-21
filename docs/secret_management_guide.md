# Guide de Gestion des Secrets pour ArgentEnveloppes

Ce document décrit le processus de gestion des secrets et des configurations sensibles pour l'application ArgentEnveloppes, en s'assurant qu'ils ne sont pas exposés dans le code source public.

## 1. Vue d'ensemble

La stratégie de gestion des secrets repose sur l'utilisation des arguments `--dart-define` lors de la compilation ou de l'exécution de l'application Flutter. Ces arguments sont peuplés à partir de variables d'environnement, qui sont définies différemment pour le développement local et pour l'intégration continue (CI/CD).

Les secrets typiques incluent les clés API Firebase, les identifiants clients OAuth, etc.

## 2. Développement Local

### Fichiers d'Environnement (`.env.<ENVIRONNEMENT>.ps1`)

Pour le développement local, les secrets sont stockés dans des fichiers PowerShell non versionnés (non présents dans Git). Un fichier typique est `.env.dev.ps1` pour l'environnement de développement.

**Structure d'un fichier `.env.dev.ps1`:**
Ces fichiers utilisent la syntaxe PowerShell pour définir des variables d'environnement.

```powershell
# .env.dev.ps1
$Env:FIREBASE_WEB_API_KEY = "VOTRE_API_KEY_ICI"
$Env:FIREBASE_AUTH_DOMAIN = "VOTRE_AUTH_DOMAIN_ICI"
$Env:FIREBASE_PROJECT_ID = "VOTRE_PROJECT_ID_ICI"
# ... autres secrets ...
$Env:FIREBASE_WEB_CLIENT_ID = "VOTRE_WEB_CLIENT_ID_POUR_GOOGLE_SIGN_IN"
```

**Important :** Ces fichiers `.env.*.ps1` **doivent être listés dans le fichier `.gitignore`** pour éviter de les pousser sur le dépôt Git.

### Script d'Exécution (`run_dev_env.ps1`)

Le script `run_dev_env.ps1` est responsable de :
1.  Charger (via "dot sourcing") le fichier `.env.<ENVIRONNEMENT>.ps1` approprié (par défaut `.env.dev.ps1`).
2.  Lire les variables d'environnement qui y sont définies (ex: `$Env:FIREBASE_WEB_API_KEY`).
3.  Construire une liste d'arguments `--dart-define=CLE=VALEUR` pour chaque secret.
4.  Exécuter `flutter run -d chrome --web-renderer html` en passant ces arguments.

Le script s'assure que les clés nécessaires (comme `FIREBASE_WEB_CLIENT_ID`) sont présentes.

## 3. Intégration Continue/Déploiement Continu (CI/CD - GitHub Actions)

Pour les builds en CI/CD, notamment pour le déploiement sur GitHub Pages via le workflow `.github/workflows/deploy-flutter-web.yml`:

1.  **Stockage des Secrets** : Les secrets sont stockés de manière sécurisée dans les "Secrets" du référentiel GitHub (`Settings > Secrets and variables > Actions`).
2.  **Utilisation dans le Workflow** : Le fichier de workflow accède à ces secrets GitHub (ex: `${{ secrets.FIREBASE_WEB_API_KEY }}`) et les transmet à la commande `flutter build web` en utilisant des arguments `--dart-define`.

Extrait pertinent du workflow (`deploy-flutter-web.yml` - à adapter) :
```yaml
# ...
jobs:
  build_and_deploy:
    # ...
    steps:
      # ...
      - name: Build Flutter web app
        run: |
          flutter build web --release \
            --base-href /ArgentEnveloppes/ \
            --dart-define=FIREBASE_WEB_API_KEY=${{ secrets.FIREBASE_WEB_API_KEY }} \
            --dart-define=FIREBASE_AUTH_DOMAIN=${{ secrets.FIREBASE_AUTH_DOMAIN }} \
            --dart-define=FIREBASE_PROJECT_ID=${{ secrets.FIREBASE_PROJECT_ID }} \
            # ... autres secrets ...
            --dart-define=FIREBASE_WEB_CLIENT_ID=${{ secrets.FIREBASE_WEB_CLIENT_ID_PROD }}
# ...
```
**Note:** Il est crucial d'utiliser des secrets distincts pour la production (ex: `FIREBASE_WEB_CLIENT_ID_PROD`) si les configurations diffèrent de celles du développement.

## 4. Utilisation dans l'Application Flutter

Une fois les secrets passés via `--dart-define`, l'application Flutter y accède en utilisant `String.fromEnvironment`.

### `lib/firebase_options.dart`

Ce fichier est configuré pour lire toutes les options Firebase nécessaires à partir des variables d'environnement.

```dart
// lib/firebase_options.dart
// ...
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // ...
    return const FirebaseOptions(
      apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY'),
      authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
      projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
      storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
      messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
      appId: String.fromEnvironment('FIREBASE_WEB_APP_ID'),
      measurementId: String.fromEnvironment('FIREBASE_MEASUREMENT_ID', defaultValue: ''), // Optionnel
    );
  }
}
```

### Autres Parties de l'Application

De même, d'autres parties du code, comme `FirebaseAuthDataSource` ou `googleSignInProvider` dans `lib/presentation/providers/auth_provider.dart`, utilisent `String.fromEnvironment` pour récupérer des configurations spécifiques (ex: `FIREBASE_WEB_CLIENT_ID`).

```dart
// Exemple dans lib/data/datasources/firebase_auth_data_source.dart
// ...
_googleSignIn = googleSignIn ?? GoogleSignIn(
  clientId: kIsWeb ? const String.fromEnvironment('FIREBASE_WEB_CLIENT_ID') : null,
);
// ...
```

## 5. Ajout de Nouveaux Secrets

Pour ajouter un nouveau secret (par exemple, `NEW_SECRET_KEY`):

1.  **Développement Local**:
    *   Ajoutez `$Env:NEW_SECRET_KEY="sa_valeur_locale"` à votre fichier `.env.dev.ps1` (et aux autres fichiers `.env.*.ps1` si vous en avez pour d'autres environnements locaux).
    *   Mettez à jour la liste `$keysToDefine` dans `run_dev_env.ps1` pour inclure `"NEW_SECRET_KEY"`.
2.  **CI/CD (GitHub Actions)**:
    *   Ajoutez `NEW_SECRET_KEY` (ou `NEW_SECRET_KEY_PROD`) aux secrets de votre référentiel GitHub.
    *   Modifiez `.github/workflows/deploy-flutter-web.yml` pour inclure `--dart-define=NEW_SECRET_KEY=${{ secrets.NEW_SECRET_KEY }}` dans l'étape `flutter build web`.
3.  **Application Flutter**:
    *   Accédez à la valeur dans votre code Dart en utilisant `const String newSecret = String.fromEnvironment('NEW_SECRET_KEY');`. Si la valeur peut être absente ou avoir une valeur par défaut, utilisez `const String.fromEnvironment('NEW_SECRET_KEY', defaultValue: 'valeur_par_defaut')`.

## 6. Sécurité

*   **NE JAMAIS COMMITTER** les fichiers `.env.*.ps1` ou tout autre fichier contenant des secrets en clair dans le dépôt Git. Assurez-vous qu'ils sont correctement listés dans `.gitignore`.
*   **NE JAMAIS CODER EN DUR** des secrets directement dans le code source (fichiers `.dart`, `.html`, etc.).
*   Pour CI/CD, utilisez les mécanismes de gestion des secrets fournis par la plateforme (ex: GitHub Secrets).
*   Appliquez le principe du moindre privilège pour les secrets utilisés en CI/CD, en ne leur donnant que les permissions nécessaires.

Ce guide devrait vous aider à gérer les secrets de manière sécurisée et efficace pour ArgentEnveloppes.
