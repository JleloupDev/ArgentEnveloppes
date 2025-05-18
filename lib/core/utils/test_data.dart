import '../../domain/entities/category.dart';
import '../../domain/entities/envelope.dart';
import '../../domain/entities/transaction.dart';

/// Classe utilitaire pour créer des données de test
class TestData {
  /// Crée des catégories de test
  static List<Category> createTestCategories() {
    return [
      const Category(id: 'cat1', name: 'Alimentation'),
      const Category(id: 'cat2', name: 'Logement'),
      const Category(id: 'cat3', name: 'Transport'),
      const Category(id: 'cat4', name: 'Loisirs'),
      const Category(id: 'cat5', name: 'Santé'),
    ];
  }
  
  /// Crée des enveloppes de test
  static List<Envelope> createTestEnvelopes() {
    return [
      const Envelope(
        id: 'env1',
        name: 'Courses',
        budget: 400,
        spent: 250,
        categoryId: 'cat1',
      ),
      const Envelope(
        id: 'env2',
        name: 'Restaurants',
        budget: 200,
        spent: 150,
        categoryId: 'cat1',
      ),
      const Envelope(
        id: 'env3',
        name: 'Loyer',
        budget: 800,
        spent: 800,
        categoryId: 'cat2',
      ),
      const Envelope(
        id: 'env4',
        name: 'Électricité',
        budget: 100,
        spent: 80,
        categoryId: 'cat2',
      ),
      const Envelope(
        id: 'env5',
        name: 'Essence',
        budget: 150,
        spent: 120,
        categoryId: 'cat3',
      ),
    ];
  }
    /// Crée des transactions de test
  static List<Transaction> createTestTransactions() {
    final now = DateTime.now();
    
    return [
      Transaction(
        id: 'tr1',
        envelopeId: 'env1',
        amount: 50,
        type: TransactionType.expense,
        comment: 'Courses au supermarché',
        date: now.subtract(const Duration(days: 5)),
      ),
      Transaction(
        id: 'tr2',
        envelopeId: 'env1',
        amount: 70,
        type: TransactionType.expense,
        comment: 'Courses hebdomadaires',
        date: now.subtract(const Duration(days: 3)),
      ),
      Transaction(
        id: 'tr3',
        envelopeId: 'env2',
        amount: 45,
        type: TransactionType.expense,
        comment: 'Restaurant avec des amis',
        date: now.subtract(const Duration(days: 2)),
      ),
      Transaction(
        id: 'tr4',
        envelopeId: 'env3',
        amount: 800,
        type: TransactionType.expense,
        comment: 'Paiement du loyer',
        date: now.subtract(const Duration(days: 10)),
      ),
      Transaction(
        id: 'tr5',
        envelopeId: 'env5',
        amount: 40,
        type: TransactionType.expense,
        comment: 'Plein d\'essence',
        date: now.subtract(const Duration(days: 4)),
      ),
    ];
  }
}
