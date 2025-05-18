import '../../domain/entities/category.dart';
import '../../domain/entities/envelope.dart';
import '../../domain/entities/transaction.dart';

/// Classe utilitaire pour fournir des données de démonstration
class DemoData {
  /// Renvoie une liste de catégories de démonstration
  static List<Category> getCategories() {
    return [
      Category(id: '1', name: 'Alimentation'),
      Category(id: '2', name: 'Logement'),
      Category(id: '3', name: 'Transport'),
      Category(id: '4', name: 'Loisirs'),
      Category(id: '5', name: 'Santé'),
    ];
  }

  /// Renvoie une liste d'enveloppes de démonstration
  static List<Envelope> getEnvelopes() {
    return [
      Envelope(
        id: '1',
        name: 'Courses',
        budget: 500.0,
        spent: 320.0,
        categoryId: '1',
      ),
      Envelope(
        id: '2',
        name: 'Restaurants',
        budget: 200.0,
        spent: 150.0,
        categoryId: '1',
      ),
      Envelope(
        id: '3',
        name: 'Loyer',
        budget: 800.0,
        spent: 800.0,
        categoryId: '2',
      ),
      Envelope(
        id: '4',
        name: 'Électricité',
        budget: 100.0,
        spent: 85.0,
        categoryId: '2',
      ),
      Envelope(
        id: '5',
        name: 'Essence',
        budget: 150.0,
        spent: 120.0,
        categoryId: '3',
      ),
      Envelope(
        id: '6',
        name: 'Cinéma',
        budget: 50.0,
        spent: 25.0,
        categoryId: '4',
      ),
    ];
  }

  /// Renvoie une liste de transactions de démonstration
  static List<Transaction> getTransactions() {
    return [      Transaction(
        id: '1',
        envelopeId: '1',
        amount: 45.0,
        type: TransactionType.expense,
        comment: 'Courses supermarché',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Transaction(
        id: '2',
        envelopeId: '1',
        amount: 35.0,
        type: TransactionType.expense,
        comment: 'Marché',
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Transaction(
        id: '3',
        envelopeId: '2',
        amount: 65.0,
        type: TransactionType.expense,
        comment: 'Restaurant italien',
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}
