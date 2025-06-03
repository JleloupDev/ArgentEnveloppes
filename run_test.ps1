# Script simple pour lancer ArgentEnveloppes en mode développement
# Sans Firebase pour les tests locaux

param (
    [Parameter(Mandatory=$false)]
    [switch]$SkipClean
)

# Aller au répertoire du projet
Set-Location -Path $PSScriptRoot

Write-Host "=== Lancement d'ArgentEnveloppes en mode développement ===" -ForegroundColor Green

if (-not $SkipClean) {
    Write-Host "Nettoyage du projet Flutter..." -ForegroundColor Yellow
    flutter clean
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Erreur lors de 'flutter clean'."
        exit $LASTEXITCODE
    }

    Write-Host "Récupération des dépendances..." -ForegroundColor Yellow
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Erreur lors de 'flutter pub get'."
        exit $LASTEXITCODE
    }
} else {
    Write-Host "Nettoyage ignoré (--SkipClean)" -ForegroundColor Yellow
}

Write-Host "Lancement de l'application sur Chrome..." -ForegroundColor Yellow
Write-Host "URL: http://localhost:8080" -ForegroundColor Cyan

# Lancer avec le main_test.dart pour éviter Firebase
flutter run -d chrome --web-port 8080 -t lib/main_test.dart

if ($LASTEXITCODE -ne 0) {
    Write-Error "Erreur lors du lancement de l'application."
    exit $LASTEXITCODE
}

Write-Host "Application lancée avec succès !" -ForegroundColor Green
