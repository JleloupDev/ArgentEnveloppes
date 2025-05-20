# Script pour tester le déploiement local de l'application Flutter Web
# Ce script simule la structure du déploiement GitHub Pages

$repoName = "ArgentEnveloppes"
$testFolder = "test_deploy"

# Créer le répertoire de test si nécessaire
if (-not (Test-Path $testFolder)) {
    New-Item -ItemType Directory -Path $testFolder | Out-Null
}

# Créer le sous-répertoire pour simuler le path GitHub Pages
if (-not (Test-Path "$testFolder\$repoName")) {
    New-Item -ItemType Directory -Path "$testFolder\$repoName" | Out-Null
}

# Copier tous les fichiers nécessaires
Write-Host "Copie des fichiers dans $testFolder\$repoName..."
Copy-Item -Path *.html -Destination "$testFolder\$repoName\" -Force
Copy-Item -Path *.js -Destination "$testFolder\$repoName\" -Force
Copy-Item -Path *.css -Destination "$testFolder\$repoName\" -Force
Copy-Item -Path *.png -Destination "$testFolder\$repoName\" -Force
Copy-Item -Path *.json -Destination "$testFolder\$repoName\" -Force
Copy-Item -Path "icons" -Destination "$testFolder\$repoName\" -Recurse -Force
Copy-Item -Path "assets" -Destination "$testFolder\$repoName\" -Recurse -Force
Copy-Item -Path "canvaskit" -Destination "$testFolder\$repoName\" -Recurse -Force

# Créer le fichier .nojekyll
"" | Set-Content -Path "$testFolder\.nojekyll"

# Créer une redirection au niveau racine
@"
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta http-equiv="refresh" content="0;url=/$repoName/">
  <script>
    window.location.href = '/$repoName/';
  </script>
  <title>Redirection</title>
</head>
<body>
  Si vous n'êtes pas redirigé automatiquement, cliquez <a href="/$repoName/">ici</a>.
</body>
</html>
"@ | Set-Content -Path "$testFolder\index.html"

# Lancer un serveur web pour tester
Write-Host "Lancement du serveur web sur http://localhost:8080/"
Write-Host "Pour tester l'application, ouvrez: http://localhost:8080/$repoName/"
Write-Host "Appuyez sur Ctrl+C pour arrêter le serveur"
Set-Location $testFolder
python -m http.server 8080
