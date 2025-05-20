# ArgentEnveloppes - Application de gestion de budget

Application de gestion de budget personnel utilisant la méthode des enveloppes budgétaires.

## Configuration Firebase pour l'authentification

Pour que l'authentification fonctionne correctement, vous devez configurer Firebase pour votre projet. Suivez ces étapes :

### 1. Créer un projet Firebase

1. Rendez-vous sur [Firebase Console](https://console.firebase.google.com/)
2. Cliquez sur "Ajouter un projet"
3. Suivez les instructions pour créer un nouveau projet

### 2. Ajouter Firebase à votre application

#### Option 1 : Utiliser FlutterFire CLI (recommandé)

1. Installez FlutterFire CLI :
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Exécutez la commande de configuration :
   ```bash
   flutterfire configure --project=your-firebase-project-id
   ```

3. Suivez les instructions pour sélectionner les plateformes (Android, iOS, Web)

#### Option 2 : Configuration manuelle

1. Dans Firebase Console, ajoutez une application pour chaque plateforme (Android, iOS, Web)
2. Téléchargez les fichiers de configuration
3. Mettez à jour le fichier `lib/firebase_options.dart` avec vos clés API

### 3. Activer l'authentification Firebase

1. Dans Firebase Console, allez dans "Authentication"
2. Activez les méthodes d'authentification :
   - Email/Mot de passe
   - Google Sign-In

### 4. Configuration pour GitHub Pages

1. Dans Firebase Console > Authentication > Settings > Authorized domains
2. Ajoutez votre domaine GitHub Pages (par exemple : `username.github.io`)

## Déploiement automatisé via GitHub Actions

Cette application est configurée pour être automatiquement déployée sur GitHub Pages à chaque push sur la branche principale (`main`).

### Comment fonctionne le déploiement automatisé

1. **Configuration**: Le workflow est défini dans le fichier `.github/workflows/deploy-flutter-web.yml`
2. **Déclenchement**: Le workflow se lance automatiquement lorsque:
   - Un push est effectué sur la branche `main`
   - Le workflow est lancé manuellement depuis l'interface GitHub (via "Actions")

3. **Étapes du workflow**:   - Récupération du code source
   - Installation de Flutter
   - Installation des dépendances
   - Analyse du code
   - Exécution des tests
   - Compilation de l'application pour le web
   - Copie des fichiers statiques requis (`styles.css`, `flutter_bootstrap.js`, `script.js`, `favicon.png`, `icons/Icon-192.png`)
   - Configuration pour GitHub Pages (ajout des fichiers `.nojekyll` et `404.html`)
   - Déploiement sur la branche `gh-pages`

4. **Accès à l'application**: Une fois déployée, l'application est accessible à l'adresse:
   `https://<votre-nom-utilisateur>.github.io/ArgentEnveloppes/`

### Configuration requise dans GitHub

Pour activer le déploiement GitHub Pages:

1. Dans les paramètres du dépôt GitHub (onglet "Settings")
2. Accéder à la section "Pages"
3. Dans "Source", sélectionner "Deploy from a branch"
4. Sélectionner la branche `gh-pages` et le dossier `/ (root)`
5. Cliquer sur "Save"

### Fichiers statiques importants

L'application nécessite les fichiers statiques suivants pour fonctionner correctement :

- `styles.css` - Styles CSS personnalisés pour l'application
- `flutter_bootstrap.js` - Script d'initialisation de Flutter pour le web
- `script.js` - Scripts personnalisés pour l'application
- `favicon.png` - Favicon du site web
- `icons/Icon-192.png` - Icône pour les installations sur mobile

Le workflow de déploiement automatique copie automatiquement ces fichiers vers le répertoire de build. Si vous rencontrez des erreurs 404 pour ces fichiers, assurez-vous qu'ils existent à la racine de votre projet et que le workflow les copie correctement.

### Déploiement manuel

Si vous préférez déployer manuellement:

```bash
# Compiler l'application
flutter build web --release --base-href "/ArgentEnveloppes/"

# Ajouter les fichiers nécessaires
touch build/web/.nojekyll

# Copier les fichiers statiques importants
cp styles.css flutter_bootstrap.js script.js favicon.png build/web/
mkdir -p build/web/icons
cp icons/Icon-192.png build/web/icons/

# Créer la branche gh-pages et pousser les fichiers
git checkout --orphan gh-pages
git rm -rf .
git add build/web/* --force
git commit -m "Deploy web app to GitHub Pages"
git push origin gh-pages --force
```
