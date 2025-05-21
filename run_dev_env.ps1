param (
    [Parameter(Mandatory=$false)]
    [string]$Environment = "dev",

    [Parameter(Mandatory=$false)]
    [switch]$SkipRestore
)

# Script pour configurer l'environnement de développement et lancer l'application

# Aller au répertoire du projet (si le script n'est pas déjà exécuté depuis là)
Set-Location -Path $PSScriptRoot

Write-Host "Valeur de \$LASTEXITCODE avant de réinitialiser: $LASTEXITCODE"
# Exécuter une commande externe simple pour s'assurer que $LASTEXITCODE est réinitialisé à 0
cmd /c "exit 0"
Write-Host "Valeur de \$LASTEXITCODE après réinitialisation (devrait être 0): $LASTEXITCODE"

Write-Host "Étape 1: Application de la configuration Firebase pour l'environnement '$Environment'..."
# Capturer toutes les sorties (standard, erreur, warning, etc.) et vérifier le succès
$applyConfigOutput = $(./apply_firebase_config.ps1 -Environment $Environment *>&1)
$applyConfigSuccess = $?
$applyConfigExitCode = $LASTEXITCODE

Write-Host "--- Début de la sortie de apply_firebase_config.ps1 ---"
if ($applyConfigOutput) {
    Write-Host $applyConfigOutput
} else {
    Write-Host "(Aucune sortie standard ou d'erreur capturée de apply_firebase_config.ps1)"
}
Write-Host "--- Fin de la sortie de apply_firebase_config.ps1 ---"
Write-Host "Status de succès de apply_firebase_config.ps1 (\$?): $applyConfigSuccess"
Write-Host "Code de sortie de apply_firebase_config.ps1 (\$LASTEXITCODE): $applyConfigExitCode"

# Vérifier si la commande précédente a réussi
# Une commande PowerShell réussie met $? à $true.
# Un script qui utilise 'exit <non-zero>' mettra $LASTEXITCODE à <non-zero> et $? à $false.
if (-not $applyConfigSuccess -or ($applyConfigExitCode -ne 0 -and $null -ne $applyConfigExitCode)) {
    Write-Error "Erreur lors de l'application de la configuration Firebase (Succès: $applyConfigSuccess, ExitCode: $applyConfigExitCode). Voir la sortie ci-dessus. Arrêt du script."
    # Tenter de sortir avec le même code d'erreur si disponible et non nul, sinon 1.
    if ($applyConfigExitCode -ne 0 -and $null -ne $applyConfigExitCode) {
        exit $applyConfigExitCode
    } else {
        exit 1
    }
}

if (-not $SkipRestore) {
    Write-Host "Étape 2: Nettoyage du projet Flutter..."
    flutter clean

    # Vérifier si la commande précédente a réussi
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Erreur lors du 'flutter clean'. Arrêt du script."
        exit $LASTEXITCODE
    }

    Write-Host "Étape 3: Récupération des dépendances Flutter..."
    flutter pub get

    # Vérifier si la commande précédente a réussi
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Erreur lors du 'flutter pub get'. Arrêt du script."
        exit $LASTEXITCODE
    }
} else {
    Write-Host "Étapes 2 & 3 (Nettoyage et Récupération des dépendances) sautées."
}

Write-Host "Étape 4: Lancement de l'application en mode développement (Chrome avec rendu HTML)..."
flutter run -d chrome

Write-Host "Script terminé."
