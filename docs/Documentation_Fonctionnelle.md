Présentation
1.1 Objectif

Argentveloppes est une application mobile et web de gestion budgétaire quotidienne, fondée sur la méthode des enveloppes. Elle permet aux utilisateurs de répartir leur budget dans différentes enveloppes de dépenses et de suivre leur consommation simplement, comme s’ils utilisaient de l’argent liquide.

1.2 Proposition de valeur

Argentveloppes se distingue par sa simplicité d’utilisation. Elle vise à :

Offrir un outil rapide et intuitif pour visualiser et ajuster ses dépenses
Fonctionner hors ligne, sans compte utilisateur
Éviter la complexité des connexions bancaires ou des outils d’analyse avancée
Reproduire l’expérience d’enveloppes physiques dans une interface numérique
Fonctionnalités principales
2.1 Tableau de bord

Vue d’ensemble de la situation budgétaire :

Total des budgets (somme des plafonds d’enveloppes)
Total des dépenses enregistrées
Reste disponible (budget − dépenses)
Accès rapide aux enveloppes via une liste
2.2 Catégories

Organisation thématique des enveloppes :

Créer une catégorie (nom)
Modifier, supprimer une catégorie
Visualiser un résumé par catégorie :
Nombre d’enveloppes
Budget total
Dépenses totales
2.3 Enveloppes

Éléments budgétaires liés à des postes de dépenses :

Créer une enveloppe avec :
Nom
Plafond budgétaire
Catégorie optionnelle
Modifier ou supprimer une enveloppe
Indicateur visuel (barre de progression) montrant la consommation :
Vert : < 80 %
Orange : 80–100 %
Rouge : > 100 %
2.4 Transactions

Enregistrement des mouvements financiers dans chaque enveloppe :

Ajouter une transaction rapide (dépense uniquement)
Ajouter une transaction détaillée depuis la vue enveloppe :
Type : Dépense ou Revenu
Montant
Description (facultative)
Supprimer une transaction
2.5 Vue détaillée d’une enveloppe

Affichage complet pour chaque enveloppe :

Informations générales : nom, plafond, dépensé, reste
Catégorie associée
Barre de progression du budget
Historique des transactions (ordre chronologique)
Formulaire d’ajout de transaction (dépense ou revenu)
2.6 Données et Portabilité

L’application fonctionne sans connexion Internet.

Toutes les données sont stockées localement sur l’appareil.

Fonctionnalités prévues :

Export CSV (enveloppes et transactions)
Import CSV pour restaurer les données
Export / import complet via un fichier de sauvegarde local (format JSON)
Contraintes & Hypothèses techniques
3.1 Plateformes cibles

Flutter Web : Application accessible via navigateur
Flutter iOS : Application native pour iPhone
Flutter Android : Application native pour Android
3.2 Authentification

Aucune inscription, aucun système de compte.

L’utilisateur a un accès direct à ses données dès l’ouverture de l’application.

Pas d’authentification biométrique.

3.3 Stockage

Stockage local uniquement dans un premier temps :

Fichiers persistants (JSON)
Accès aux fichiers du système de l’appareil pour sauvegarde / restauration manuelle
3.4 Mode hors ligne

L’intégralité des fonctionnalités est utilisable sans connexion Internet.

Aucune dépendance à un serveur distant.

Interface utilisateur – principes directeurs
L’expérience utilisateur repose sur :

Une navigation simple et rapide (tableau de bord → enveloppe → transaction)
Des boutons clairs pour les actions principales (ajout, suppression)
Des couleurs explicites pour signaler l’état du budget (vert/orange/rouge)
Une hiérarchie visuelle claire pour la lecture rapide des données clés
Roadmap fonctionnelle – MVP
Priorité haute (Obligatoire dès la v1) :

☑ Tableau de bord
☑ Création/modification/suppression d’enveloppes
☑ Ajout/suppression de transactions
☑ Vue détaillée d’enveloppe
☑ Organisation par catégories
☑ Calculs automatiques (budget total, consommé, reste)
☑ Barre de progression visuelle par enveloppe
☑ Export CSV
☑ Import CSV
☑ Sauvegarde et restauration JSON

Fonctionnalités futures possibles (non incluses dans le MVP) :

⛔ Statistiques graphiques
⛔ Objectifs d’épargne
⛔ Notifications ou rappels
⛔ Comptes multiples
⛔ Synchronisation cloud
⛔ Authentification utilisateur

Internationalisation
Langue supportée dans le MVP : Français
Prévision multilingue ultérieure : Oui (Anglais, Espagnol)

Annexes techniques à produire (hors documentation fonctionnelle)
À concevoir pour le développement Flutter :

Modèles de données :
EnvelopeModel
TransactionModel
CategoryModel
Services :
StorageService (local storage JSON)
CsvExporter / CsvImporter
BudgetCalculatorService
Routage et navigation :
HomePage > CategoryPage > EnvelopePage > TransactionPage
Composants UI :
BudgetProgressBar
TransactionListItem
EnvelopeCard