# ArgentEnveloppes - Application de gestion de budget

Application de gestion de budget personnel utilisant la méthode des enveloppes budgétaires.

## Déploiement automatisé via GitHub Actions

Cette application est configurée pour être automatiquement déployée sur GitHub Pages à chaque push sur la branche principale (`main`).

### Comment fonctionne le déploiement automatisé

1. **Configuration**: Le workflow est défini dans le fichier `.github/workflows/deploy-flutter-web.yml`
2. **Déclenchement**: Le workflow se lance automatiquement lorsque:
   - Un push est effectué sur la branche `main`
   - Le workflow est lancé manuellement depuis l'interface GitHub (via "Actions")

3. **Étapes du workflow**:
   - Récupération du code source
   - Installation de Flutter
   - Installation des dépendances
   - Analyse du code
   - Exécution des tests
   - Compilation de l'application pour le web
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

### Déploiement manuel

Si vous préférez déployer manuellement:

```bash
# Compiler l'application
flutter build web --release --base-href "/ArgentEnveloppes/"

# Ajouter les fichiers nécessaires
touch build/web/.nojekyll

# Créer la branche gh-pages et pousser les fichiers
git checkout --orphan gh-pages
git rm -rf .
git add build/web/* --force
git commit -m "Deploy web app to GitHub Pages"
git push origin gh-pages --force
```
