# Apply Firebase Configuration
# Ce script applique la configuration Firebase à tous les fichiers nécessaires dans le projet
# Il utilise les variables d'environnement définies dans .env.*.ps1

param (
    [Parameter()]
    [string]$Environment = "dev"
)

# Vérifier si le fichier d'environnement existe
$envFile = ".env.$Environment.ps1"
if (-not (Test-Path $envFile)) {
    Write-Error "Le fichier d'environnement $envFile n'existe pas. Créez-le à partir de .env.example.ps1"
    exit 1
}

# Charger les variables d'environnement
Write-Host "Chargement des variables d'environnement depuis $envFile..."
. "./$envFile"

# Vérifier que les variables essentielles sont définies
$requiredVars = @(
    "FIREBASE_WEB_API_KEY",
    "FIREBASE_AUTH_DOMAIN",
    "FIREBASE_PROJECT_ID",
    "FIREBASE_STORAGE_BUCKET",
    "FIREBASE_MESSAGING_SENDER_ID", 
    "FIREBASE_WEB_APP_ID",
    "FIREBASE_WEB_CLIENT_ID" # <--- AJOUTER CETTE LIGNE
)

$missingVars = @()
foreach ($var in $requiredVars) {
    if ([string]::IsNullOrEmpty((Get-Item "Env:$var" -ErrorAction SilentlyContinue).Value)) {
        $missingVars += $var
    }
}

if ($missingVars.Count -gt 0) {
    Write-Error "Variables manquantes: $($missingVars -join ', ')"
    exit 1
}

# 1. Mettre à jour firebase_options.dart
Write-Host "Mise à jour du fichier firebase_options.dart..."
$firebaseOptionsPath = "lib/firebase_options.dart"
$firebaseOptionsContent = Get-Content $firebaseOptionsPath -Raw

# Mettre à jour la configuration web
$firebaseOptionsContent = $firebaseOptionsContent -replace "apiKey: 'YOUR_WEB_API_KEY'", "apiKey: '$Env:FIREBASE_WEB_API_KEY'"
$firebaseOptionsContent = $firebaseOptionsContent -replace "appId: 'YOUR_WEB_APP_ID'", "appId: '$Env:FIREBASE_WEB_APP_ID'"
$firebaseOptionsContent = $firebaseOptionsContent -replace "messagingSenderId: 'YOUR_WEB_MESSAGING_SENDER_ID'", "messagingSenderId: '$Env:FIREBASE_MESSAGING_SENDER_ID'"
$firebaseOptionsContent = $firebaseOptionsContent -replace "projectId: 'YOUR_PROJECT_ID'", "projectId: '$Env:FIREBASE_PROJECT_ID'"
$firebaseOptionsContent = $firebaseOptionsContent -replace "authDomain: 'YOUR_AUTH_DOMAIN'", "authDomain: '$Env:FIREBASE_AUTH_DOMAIN'"
$firebaseOptionsContent = $firebaseOptionsContent -replace "storageBucket: 'YOUR_STORAGE_BUCKET'", "storageBucket: '$Env:FIREBASE_STORAGE_BUCKET'"

# Mettre à jour la configuration Android si disponible
if (-not [string]::IsNullOrEmpty($Env:FIREBASE_ANDROID_API_KEY)) {
    $firebaseOptionsContent = $firebaseOptionsContent -replace "apiKey: 'YOUR_ANDROID_API_KEY'", "apiKey: '$Env:FIREBASE_ANDROID_API_KEY'"
}
if (-not [string]::IsNullOrEmpty($Env:FIREBASE_ANDROID_APP_ID)) {
    $firebaseOptionsContent = $firebaseOptionsContent -replace "appId: 'YOUR_ANDROID_APP_ID'", "appId: '$Env:FIREBASE_ANDROID_APP_ID'"
}

# Mettre à jour la configuration iOS si disponible
if (-not [string]::IsNullOrEmpty($Env:FIREBASE_IOS_API_KEY)) {
    $firebaseOptionsContent = $firebaseOptionsContent -replace "apiKey: 'YOUR_IOS_API_KEY'", "apiKey: '$Env:FIREBASE_IOS_API_KEY'"
}
if (-not [string]::IsNullOrEmpty($Env:FIREBASE_IOS_APP_ID)) {
    $firebaseOptionsContent = $firebaseOptionsContent -replace "appId: 'YOUR_IOS_APP_ID'", "appId: '$Env:FIREBASE_IOS_APP_ID'"
}
if (-not [string]::IsNullOrEmpty($Env:FIREBASE_IOS_CLIENT_ID)) {
    $firebaseOptionsContent = $firebaseOptionsContent -replace "iosClientId: 'YOUR_IOS_CLIENT_ID'", "iosClientId: '$Env:FIREBASE_IOS_CLIENT_ID'"
}
if (-not [string]::IsNullOrEmpty($Env:FIREBASE_IOS_BUNDLE_ID)) {
    $firebaseOptionsContent = $firebaseOptionsContent -replace "iosBundleId: 'YOUR_IOS_BUNDLE_ID'", "iosBundleId: '$Env:FIREBASE_IOS_BUNDLE_ID'"
}

# Enregistrer les modifications
Set-Content -Path $firebaseOptionsPath -Value $firebaseOptionsContent
Write-Host "✓ Fichier firebase_options.dart mis à jour"

# 2. Mettre à jour index.html
Write-Host "Mise à jour du fichier index.html..."
$indexHtmlPath = "index.html" # Assurez-vous que c'est le bon chemin, ex: "web/index.html" ou "./index.html"
if (Test-Path $indexHtmlPath) {
    $indexHtmlContent = Get-Content $indexHtmlPath -Raw

    # Mettre à jour le Google Sign-In Client ID
    $indexHtmlContent = $indexHtmlContent -replace '__GOOGLE_SIGN_IN_CLIENT_ID_PLACEHOLDER__', $Env:FIREBASE_WEB_CLIENT_ID
    
    # Le remplacement du bloc firebaseConfig peut être supprimé si l'initialisation se fait uniquement via firebase_options.dart
    # Si vous gardez l'initialisation Firebase JS dans index.html (ce qui n'est plus recommandé ici),
    # assurez-vous que $Env:FIREBASE_WEB_CLIENT_ID est aussi inclus là si nécessaire.
    # Pour l'instant, nous nous concentrons sur le meta tag.

    # Enregistrer les modifications pour le Client ID
    Set-Content -Path $indexHtmlPath -Value $indexHtmlContent
    Write-Host "✓ Fichier index.html mis à jour (Google Client ID)"

} else {
    Write-Warning "Le fichier $indexHtmlPath n'existe pas dans le répertoire courant, ignoré."
    # Si votre index.html est dans web/, changez $indexHtmlPath en "web/index.html"
}

Write-Host "Configuration Firebase appliquée avec succès pour l'environnement '$Environment'."

# Afficher un résumé
Write-Host "`nRésumé de la configuration :"
Write-Host "---------------------------------------"
Write-Host "Projet Firebase : $Env:FIREBASE_PROJECT_ID"
Write-Host "Domaine d'authentification : $Env:FIREBASE_AUTH_DOMAIN"
Write-Host "Environnement : $Environment"
Write-Host "---------------------------------------"
Write-Host "`nPour modifier cette configuration :"
Write-Host "1. Éditez le fichier $envFile"
Write-Host "2. Relancez ce script : ./apply_firebase_config.ps1 -Environment $Environment"
