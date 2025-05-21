param (
    [Parameter(Mandatory=$false)]
    [string]$Environment = "dev",

    [Parameter(Mandatory=$false)]
    [switch]$SkipRestore
)

# Script pour configurer l'environnement de développement et lancer l'application

# Aller au répertoire du projet (si le script n'est pas déjà exécuté depuis là)
Set-Location -Path $PSScriptRoot

Write-Host "Étape 1: Chargement de la configuration d'environnement depuis .env.$Environment.ps1..."
$envFilePath = ".\env.$Environment.ps1"
if (-not (Test-Path $envFilePath)) {
    Write-Error "Fichier de configuration d'environnement $envFilePath non trouvé. Arrêt du script."
    exit 1
}

# Exécute le script .env pour charger les variables dans la session COURANTE
. $envFilePath
Write-Host "Configuration $Environment chargée."

$dartDefineArgs = [System.Collections.Generic.List[string]]::new()

# Clés à lire depuis l'environnement et à passer en --dart-define
# Assurez-vous que ces variables sont bien définies par $Env:MA_VARIABLE = "valeur" dans le .env.*.ps1
$keysToDefine = @(
    "FIREBASE_WEB_API_KEY",
    "FIREBASE_AUTH_DOMAIN",
    "FIREBASE_PROJECT_ID",
    "FIREBASE_STORAGE_BUCKET",
    "FIREBASE_MESSAGING_SENDER_ID",
    "FIREBASE_WEB_APP_ID",
    "FIREBASE_MEASUREMENT_ID",
    "FIREBASE_WEB_CLIENT_ID"
)

foreach ($key in $keysToDefine) {
    $value = (Get-Item "Env:$key" -ErrorAction SilentlyContinue).Value
    if ($null -ne $value -and $value -ne "") {
        $dartDefineArgs.Add("--dart-define=$key=$value")
    } else {
        Write-Warning "La variable d'environnement $key n'est pas définie ou est vide."
    }
}

# Vérifier si FIREBASE_WEB_CLIENT_ID est défini, car il est critique
$webClientIdDefined = $dartDefineArgs | Where-Object { $_ -like "*FIREBASE_WEB_CLIENT_ID*" }
if (-not $webClientIdDefined) {
    Write-Warning "FIREBASE_WEB_CLIENT_ID n'est pas défini via --dart-define. Google Sign-In sur le Web pourrait ne pas fonctionner."
}


if (-not $SkipRestore) {
    Write-Host "Étape 2: Nettoyage du projet Flutter..."
    flutter clean
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Erreur lors de 'flutter clean'."
        exit $LASTEXITCODE
    }

    Write-Host "Étape 3: Récupération des dépendances Flutter..."
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Erreur lors de 'flutter pub get'."
        exit $LASTEXITCODE
    }
} else {
    Write-Host "Étapes 2 & 3 ignorées."
}

Write-Host "Étape 4: Lancement de l'application Flutter..."
$finalDartDefines = $dartDefineArgs -join " "
Write-Host "Commande: flutter run -d chrome --web-renderer html $finalDartDefines"
flutter run -d chrome --web-renderer html @dartDefineArgs # Splatting pour les arguments

if ($LASTEXITCODE -ne 0) {
    Write-Error "Erreur lors de 'flutter run'."
    exit $LASTEXITCODE
}

Write-Host "Application lancée."
