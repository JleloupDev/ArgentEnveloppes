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

---

## 11. Bonnes pratiques de développement

### 11.1 Organisation des providers

Pour faciliter la maintenance et respecter la Clean Architecture, les providers sont organisés comme suit :

```dart
// Provider pour la source de données
final localStorageDataSourceProvider = Provider<LocalStorageDataSource>((ref) {
  return LocalStorageDataSource();
});

// Provider pour l'implémentation du repository
final budgetRepositoryImplProvider = Provider<BudgetRepository>((ref) {
  final dataSource = ref.watch(localStorageDataSourceProvider);
  return BudgetRepositoryImpl(dataSource);
});

// Provider pour accéder au repository
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return ref.watch(budgetRepositoryImplProvider);
});

// Providers pour les use cases
final createCategoryUseCaseProvider = Provider<CreateCategory>((ref) {
  return CreateCategory(ref.watch(budgetRepositoryProvider));
});
```

### 11.2 Utilisation des Use Cases dans l'UI

Toute opération métier doit passer par un use case et non directement par le repository :

```dart
// Exemple de création d'une catégorie dans l'UI
final createCategory = ref.read(createCategoryUseCaseProvider);
await createCategory(newCategory);

// Après l'opération, mise à jour des données
ref.read(categoryProvider.notifier).addCategory(newCategory);
ref.invalidate(categoriesProvider);
```

### 11.3 Gestion des erreurs

Toutes les opérations qui interagissent avec les données doivent être gérées dans un bloc try/catch :

```dart
try {
  // Utiliser le use case
  final createCategory = ref.read(createCategoryUseCaseProvider);
  await createCategory(newCategory);
  
  // Mise à jour de l'UI
  ref.invalidate(categoriesProvider);
} catch (e) {
  // Affichage de l'erreur
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Erreur lors de l'opération'))
  );
}
```

### 11.4 Flux de données

Le flux de données suit un schéma unidirectionnel :

1. **UI → Use Case → Repository → DataSource → Stockage**
2. **Stockage → DataSource → Repository → Use Case → UI**

L'utilisation de ce flux garantit la cohérence des données et facilite le débogage.