# Convention Technique & Spécifications Génératives – Projet Argentveloppes

> Ce document définit les contraintes techniques, l’architecture, les modèles métier et les structures attendues afin d'encadrer rigoureusement la génération de code par une IA ou un générateur automatique.

---

## 1. Généralités

### 1.1 Nom du projet

argentveloppes

### 1.2 Langage & Framework

- Dart >= 3.0  
- Flutter >= 3.10  
- Architecture : Clean Architecture modulaire  
- Gestion d’état : Riverpod (recommandé)  

### 1.3 Principes directeurs

- Séparation stricte des couches : présentation / domaine / données  
- Structure des fichiers modulaire et immuable autant que possible  
- Nom des classes, méthodes et fichiers explicite et cohérent  
- Aucune logique métier dans les widgets UI  

---

## 2. Arborescence de fichiers (standardisée)

```text
lib/
├── main.dart
├── core/
│   ├── constants/
│   ├── exceptions/
│   └── utils/
├── data/
│   ├── datasources/
│   │   └── local_storage_datasource.dart
│   ├── models/
│   │   ├── envelope_model.dart
│   │   ├── transaction_model.dart
│   │   └── category_model.dart
│   └── repositories_impl/
│       └── budget_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── envelope.dart
│   │   ├── transaction.dart
│   │   └── category.dart
│   ├── repositories/
│   │   └── budget_repository.dart
│   └── usecases/
│       ├── add_transaction.dart
│       ├── create_envelope.dart
│       ├── get_dashboard_data.dart
│       ├── export_csv.dart
│       └── import_csv.dart
├── presentation/
│   ├── pages/
│   │   ├── dashboard_page.dart
│   │   ├── envelope_detail_page.dart
│   │   ├── add_transaction_page.dart
│   │   └── category_management_page.dart
│   ├── providers/
│   │   └── envelope_provider.dart
│   └── widgets/
│       ├── envelope_card.dart
│       ├── budget_progress_bar.dart
│       └── transaction_list_item.dart
```

---

## 3. Modèles de données (Data Layer)

### 3.1 envelope_model.dart

```dart
class EnvelopeModel {
  final String id;
  final String name;
  final double budget;
  final double spent;
  final String? categoryId;

  EnvelopeModel({
    required this.id,
    required this.name,
    required this.budget,
    required this.spent,
    this.categoryId,
  });

  factory EnvelopeModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### 3.2 transaction_model.dart

```dart
class TransactionModel {
  final String id;
  final String envelopeId;
  final double amount;
  final String type; // 'expense' | 'income'
  final String description;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.envelopeId,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### 3.3 category_model.dart

```dart
class CategoryModel {
  final String id;
  final String name;

  CategoryModel({
    required this.id,
    required this.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

---

## 4. Entités (Domain Layer)

### envelope.dart

```dart
class Envelope {
  final String id;
  final String name;
  final double budget;
  final double spent;
  final String? categoryId;
}
```

### transaction.dart

```dart
enum TransactionType { expense, income }

class Transaction {
  final String id;
  final String envelopeId;
  final double amount;
  final TransactionType type;
  final String description;
  final DateTime date;
}
```

### category.dart

```dart
class Category {
  final String id;
  final String name;
}
```

---

## 5. Repositories (abstractions)

```dart
abstract class BudgetRepository {
  Future<List<Envelope>> getAllEnvelopes();
  Future<void> createEnvelope(Envelope envelope);
  Future<void> deleteEnvelope(String envelopeId);

  Future<List<Transaction>> getTransactionsByEnvelope(String envelopeId);
  Future<void> addTransaction(Transaction transaction);

  Future<List<Category>> getCategories();
  Future<void> createCategory(Category category);

  Future<void> exportAsCsv();
  Future<void> importFromCsv(String filePath);

  Future<void> backupToJson();
  Future<void> restoreFromJson(String filePath);
}
```

---

## 6. Cas d’usage (Use Cases)

Chaque cas d’usage est une classe indépendante avec une méthode call().

Exemple :

```dart
class CreateEnvelope {
  final BudgetRepository repository;

  CreateEnvelope(this.repository);

  Future<void> call(Envelope envelope) {
    return repository.createEnvelope(envelope);
  }
}
```

Fichiers associés dans domain/usecases/ :

- create_envelope.dart  
- delete_envelope.dart  
- add_transaction.dart  
- get_dashboard_data.dart  
- export_csv.dart  
- import_csv.dart  
- backup_to_json.dart  
- restore_from_json.dart  

---

## 7. Interfaces utilisateur (UI Layer)

### Pages principales

- DashboardPage : liste des enveloppes et synthèse budgétaire.
- EnvelopeDetailPage : détail d’une enveloppe + transactions.
- AddTransactionPage : formulaire de transaction.
- CategoryManagementPage : création / édition / suppression de catégories.

### Widgets réutilisables

- EnvelopeCard  
- BudgetProgressBar  
- TransactionListItem  

### Providers (Riverpod)

Exemple :

```dart
final envelopeProvider = StateNotifierProvider<EnvelopeNotifier, List<Envelope>>(
 (ref) => EnvelopeNotifier(),
);
```

---

## 8. Contraintes pour la génération IA

### ✅ Ce que l’IA peut faire

- Générer les implémentations à partir des interfaces fournies.
- Générer les méthodes fromJson / toJson.
- Créer les fichiers UI en suivant strictement la nomenclature.
- Générer les usecases selon la structure définie.

### ❌ Ce que l’IA ne doit pas faire

- Modifier la structure des entités ou modèles sans validation humaine.
- Fusionner plusieurs responsabilités dans une même classe.
- Modifier l’arborescence des fichiers.
- Ajouter de la logique métier dans les widgets.
- Ajouter des dépendances externes non validées.

---

## 9. Évolutivité maîtrisée

Toutes les évolutions doivent se faire par extension :

| Type d’ajout           | Dossier cible                          |
|------------------------|----------------------------------------|
| Nouveau use case       | domain/usecases/                       |
| Nouvelle entité        | domain/entities/                       |
| Nouveau modèle         | data/models/                           |
| Nouvelle page UI       | presentation/pages/                    |
| Nouveau widget         | presentation/widgets/                  |

---

## 10. Tests

Structure recommandée :

```text
test/
├── data/
├── domain/
├── presentation/
├── usecases/
```

Tests requis :

- Tests unitaires pour les repositories et usecases  
- Tests de conversion JSON ↔️ modèle  
- Tests widget pour les composants UI  