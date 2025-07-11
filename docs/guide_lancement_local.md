# Guide de Lancement Local - ArgentEnveloppes

## 📋 Prérequis

### 1. Outils nécessaires
- **Flutter SDK** (version 3.0.0 ou supérieure)
- **Dart SDK** (inclus avec Flutter)
- **Git** pour cloner le repository
- **PowerShell** (pour Windows)
- **Chrome** ou autre navigateur (pour le développement web)

### 2. Vérification de l'installation Flutter
```powershell
# Vérifier que Flutter est installé et configuré
flutter doctor

# La sortie doit montrer :
# ✓ Flutter (Channel stable, 3.x.x)
# ✓ Chrome - develop for the web
```

## 🚀 Lancement rapide

### Méthode 1 : Script automatisé (Recommandé)
```powershell
# 1. Naviguer vers le dossier du projet
cd c:\Users\jlelo\source\repos\ArgentEnveloppes

# 2. Lancer le script de développement
.\run_dev_env.ps1
```

### Méthode 2 : Commandes manuelles
```powershell
# 1. Naviguer vers le projet
cd c:\Users\jlelo\source\repos\ArgentEnveloppes

# 2. Nettoyer le projet
flutter clean

# 3. Récupérer les dépendances
flutter pub get

# 4. Lancer l'application sur Chrome
flutter run -d chrome --web-port 5000
```

## ⚙️ Configuration détaillée

### 1. Configuration Firebase
Le projet est déjà configuré avec Firebase. Les variables d'environnement sont dans `.env.dev.ps1` :

```powershell
# Les variables sont automatiquement chargées par le script run_dev_env.ps1
$Env:FIREBASE_PROJECT_ID = "argentenveloppes"
$Env:FIREBASE_WEB_API_KEY = "AIzaSyAtu1xB90m8T3IGOO__IaocA6oe-S2ScRg"
# ... autres variables
```

### 2. Ports et URLs
- **Port de développement** : `http://localhost:5000`
- **Hot reload** : Activé automatiquement
- **DevTools** : Disponibles dans la console

### 3. Structure des commandes

#### Script principal (`run_dev_env.ps1`)
Le script effectue automatiquement :
1. ✅ Chargement des variables d'environnement Firebase
2. ✅ Nettoyage du projet (`flutter clean`)
3. ✅ Installation des dépendances (`flutter pub get`)
4. ✅ Lancement sur Chrome avec port 5000
5. ✅ Configuration des variables Dart Define pour Firebase

#### Options du script
```powershell
# Lancement normal
.\run_dev_env.ps1

# Ignorer le nettoyage/restauration (plus rapide)
.\run_dev_env.ps1 -SkipRestore

# Utiliser un environnement spécifique
.\run_dev_env.ps1 -Environment "dev"
```

## 🔧 Résolution des problèmes courants

### Problème 1 : "flutter not found"
```powershell
# Vérifier l'installation Flutter
flutter doctor

# Si Flutter n'est pas trouvé, l'ajouter au PATH :
# Ajouter le chemin Flutter à vos variables d'environnement système
```

### Problème 2 : Erreurs de dépendances
```powershell
# Forcer la réinstallation des dépendances
flutter clean
flutter pub get
flutter pub deps
```

### Problème 3 : Port déjà utilisé
```powershell
# Utiliser un port différent
flutter run -d chrome --web-port 5001

# Ou tuer les processus sur le port 5000
netstat -ano | findstr :5000
taskkill /F /PID <PID_NUMBER>
```

### Problème 4 : Erreurs Firebase
```powershell
# Vérifier que les variables d'environnement sont chargées
Get-ChildItem Env: | Where-Object Name -like "*FIREBASE*"

# Si aucune variable n'apparaît, relancer le script :
.\run_dev_env.ps1
```

### Problème 5 : Chrome ne s'ouvre pas automatiquement
```powershell
# Lancer manuellement après le démarrage
# Aller sur : http://localhost:5000
```

## 🧪 Tests et développement

### Lancer les tests
```powershell
# Tests unitaires
flutter test

# Tests avec script dédié
.\run_test.ps1
```

### Hot Reload pendant le développement
- **`r`** : Hot reload (recharger le code)
- **`R`** : Hot restart (redémarrer l'application)
- **`q`** : Quitter
- **`h`** : Aide

### Outils de développement
```powershell
# Ouvrir les DevTools Flutter dans le navigateur
# L'URL sera affichée dans la console lors du lancement
```

## 📱 Support multi-plateforme

### Lancer sur différentes plateformes
```powershell
# Web (Chrome) - par défaut
flutter run -d chrome

# Web (Edge)
flutter run -d edge

# Windows (si configuré)
flutter run -d windows

# Voir tous les appareils disponibles
flutter devices
```

## 🔄 Workflow de développement recommandé

1. **Première utilisation**
   ```powershell
   git clone <repo-url>
   cd ArgentEnveloppes
   .\run_dev_env.ps1
   ```

2. **Développement quotidien**
   ```powershell
   # Lancement rapide (évite le nettoyage)
   .\run_dev_env.ps1 -SkipRestore
   ```

3. **Après modifications majeures**
   ```powershell
   # Nettoyage complet
   .\run_dev_env.ps1
   ```

## 📊 Monitoring et debugging

### Variables d'environnement actives
Le script affiche automatiquement les variables Firebase chargées :
```
Configuration dev chargée.
Commande: flutter run -d chrome --dart-define=FIREBASE_WEB_API_KEY=... --dart-define=FIREBASE_PROJECT_ID=argentenveloppes ...
```

### Logs de l'application
- Les logs Flutter apparaissent dans la console PowerShell
- Les erreurs Firebase sont visibles dans les DevTools du navigateur
- Les logs Firestore sont disponibles dans la console Firebase

## 🎯 URLs importantes

- **Application locale** : http://localhost:5000
- **Firebase Console** : https://console.firebase.google.com/project/argentenveloppes
- **Firestore Database** : https://console.firebase.google.com/project/argentenveloppes/firestore

## 💡 Conseils de productivité

1. **Utilisez le Hot Reload** : Modifiez le code et tapez `r` pour voir les changements instantanément
2. **DevTools** : Utilisez les DevTools Flutter pour debugger l'état de l'application
3. **Script rapide** : Utilisez `-SkipRestore` pour des lancements plus rapides
4. **Multi-onglets** : Vous pouvez ouvrir plusieurs onglets sur http://localhost:5000 pour tester

Le projet est maintenant prêt pour le développement local avec une intégration Firebase complète et un système de données isolé par utilisateur !
