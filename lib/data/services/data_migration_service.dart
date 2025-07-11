import 'package:firebase_auth/firebase_auth.dart';
import '../domain/entities/envelope.dart';
import '../domain/entities/category.dart';
import '../domain/repositories/budget_repository.dart';

class DataMigrationService {
  final BudgetRepository _repository;
  final FirebaseAuth _auth;

  DataMigrationService({
    required BudgetRepository repository,
    FirebaseAuth? auth,
  }) : _repository = repository,
        _auth = auth ?? FirebaseAuth.instance;

  /// Migrate demo data to Firestore for the current user
  Future<void> migrateDemoData() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to migrate data');
    }

    try {
      // Check if user already has data
      final existingEnvelopes = await _repository.getEnvelopes();
      if (existingEnvelopes.isNotEmpty) {
        throw Exception('User already has data. Migration skipped.');
      }

      // Create default categories
      final categories = await _createDefaultCategories();
      
      // Create default envelopes
      await _createDefaultEnvelopes(categories);
      
      print('Demo data migration completed successfully');
    } catch (e) {
      print('Migration failed: $e');
      rethrow;
    }
  }

  Future<List<Category>> _createDefaultCategories() async {
    final categories = [
      Category(id: 'cat_1', name: 'Alimentation'),
      Category(id: 'cat_2', name: 'Transport'),
      Category(id: 'cat_3', name: 'Loisirs'),
      Category(id: 'cat_4', name: 'Santé'),
    ];

    for (final category in categories) {
      await _repository.createCategory(category);
    }

    return categories;
  }

  Future<void> _createDefaultEnvelopes(List<Category> categories) async {
    final envelopes = [
      Envelope(
        id: 'env_1',
        name: 'Courses',
        budget: 400.0,
        spent: 150.0,
        categoryId: categories[0].id, // Alimentation
      ),
      Envelope(
        id: 'env_2',
        name: 'Essence',
        budget: 300.0,
        spent: 180.0,
        categoryId: categories[1].id, // Transport
      ),
      Envelope(
        id: 'env_3',
        name: 'Restaurants',
        budget: 200.0,
        spent: 120.0,
        categoryId: categories[0].id, // Alimentation
      ),
      Envelope(
        id: 'env_4',
        name: 'Cinéma',
        budget: 100.0,
        spent: 0.0,
        categoryId: categories[2].id, // Loisirs
      ),
      Envelope(
        id: 'env_5',
        name: 'Pharmacie',
        budget: 150.0,
        spent: 45.0,
        categoryId: categories[3].id, // Santé
      ),
    ];

    for (final envelope in envelopes) {
      await _repository.createEnvelope(envelope);
    }
  }

  /// Clear all user data (for testing purposes)
  Future<void> clearAllData() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to clear data');
    }

    try {
      // Delete all envelopes
      final envelopes = await _repository.getEnvelopes();
      for (final envelope in envelopes) {
        await _repository.deleteEnvelope(envelope.id);
      }

      // Delete all categories
      final categories = await _repository.getCategories();
      for (final category in categories) {
        await _repository.deleteCategory(category.id);
      }

      // Delete all transactions
      final transactions = await _repository.getTransactions();
      for (final transaction in transactions) {
        await _repository.deleteTransaction(transaction.id);
      }

      print('All user data cleared successfully');
    } catch (e) {
      print('Failed to clear data: $e');
      rethrow;
    }
  }
}
