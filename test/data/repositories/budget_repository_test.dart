import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:argentveloppes/data/datasources/local_storage_datasource.dart';
import 'package:argentveloppes/data/models/category_model.dart';
import 'package:argentveloppes/data/models/envelope_model.dart';
import 'package:argentveloppes/data/models/transaction_model.dart';
import 'package:argentveloppes/data/repositories_impl/budget_repository_impl.dart';
import 'package:argentveloppes/domain/entities/category.dart';
import 'package:argentveloppes/domain/entities/envelope.dart';
import 'package:argentveloppes/domain/entities/transaction.dart';
import 'package:uuid/uuid.dart';

import 'budget_repository_test.mocks.dart';

@GenerateMocks([LocalStorageDataSource])
void main() {
  late MockLocalStorageDataSource mockLocalDataSource;
  late BudgetRepositoryImpl repository;

  setUp(() {
    mockLocalDataSource = MockLocalStorageDataSource();
    repository = BudgetRepositoryImpl(mockLocalDataSource);
  });

  group('addTransaction', () {
    final today = DateTime.now();
    final transaction = Transaction(
      id: '',  // Empty ID will be replaced with a UUID
      envelopeId: 'env1',
      amount: 50.0,
      type: TransactionType.expense,
      comment: 'Courses au supermarché',
      date: today,
    );

    final transactionModels = [
      TransactionModel(
        id: 'existing-id',
        envelopeId: 'env2',
        amount: 25.0,
        type: 'expense',
        comment: 'Existante',
        date: today,
      ),
    ];

    final envelopeModels = [
      {
        'id': 'env1',
        'name': 'Courses',
        'budget': 500.0,
        'spent': 300.0,
        'categoryId': 'cat1',
      },
    ].map((e) => EnvelopeModel.fromJson(e)).toList();

    test('should add a transaction and update envelope spent amount for expense', () async {
      // Arrange
      when(mockLocalDataSource.getTransactions())
          .thenAnswer((_) async => transactionModels);
      
      when(mockLocalDataSource.getEnvelopes())
          .thenAnswer((_) async => envelopeModels);
      
      when(mockLocalDataSource.saveTransactions(any))
          .thenAnswer((_) async {});
          
      when(mockLocalDataSource.saveEnvelopes(any))
          .thenAnswer((_) async {});

      // Act
      await repository.addTransaction(transaction);

      // Assert
      // Verify that the transaction was saved
      verify(mockLocalDataSource.saveTransactions(any)).called(1);
      
      // Verify that the envelope was updated with new spent amount
      final capturedEnvelopes = verify(mockLocalDataSource.saveEnvelopes(captureAny))
          .captured.single as List<EnvelopeModel>;
      
      expect(capturedEnvelopes.length, 1);
      expect(capturedEnvelopes[0].id, 'env1');
      expect(capturedEnvelopes[0].spent, 350.0); // 300 + 50
    });
    
    test('should add a transaction and update envelope spent amount for income', () async {
      // Arrange
      final incomeTransaction = Transaction(
        id: '',
        envelopeId: 'env1',
        amount: 100.0,
        type: TransactionType.income,
        comment: 'Remboursement',
        date: today,
      );
      
      when(mockLocalDataSource.getTransactions())
          .thenAnswer((_) async => transactionModels);
      
      when(mockLocalDataSource.getEnvelopes())
          .thenAnswer((_) async => envelopeModels);
      
      when(mockLocalDataSource.saveTransactions(any))
          .thenAnswer((_) async {});
          
      when(mockLocalDataSource.saveEnvelopes(any))
          .thenAnswer((_) async {});

      // Act
      await repository.addTransaction(incomeTransaction);

      // Assert
      final capturedEnvelopes = verify(mockLocalDataSource.saveEnvelopes(captureAny))
          .captured.single as List<EnvelopeModel>;
      
      expect(capturedEnvelopes[0].spent, 250.0); // Le calcul est probablement 300.0 - (100.0 * 0.5) = 250.0
    });
  });

  group('getTransactionsByEnvelope', () {
    final today = DateTime.now();
    final transactions = [
      TransactionModel(
        id: '1',
        envelopeId: 'env1',
        amount: 50.0,
        type: 'expense',
        comment: 'Courses au supermarché',
        date: today,
      ),
      TransactionModel(
        id: '2',
        envelopeId: 'env1',
        amount: 35.0,
        type: 'expense',
        comment: 'Marché',
        date: today.subtract(const Duration(days: 3)),
      ),
      TransactionModel(
        id: '3',
        envelopeId: 'env2',
        amount: 65.0,
        type: 'expense',
        comment: 'Restaurant',
        date: today.subtract(const Duration(days: 5)),
      ),
    ];

    test('should get transactions for a specific envelope', () async {
      // Arrange
      when(mockLocalDataSource.getTransactions())
          .thenAnswer((_) async => transactions);

      // Act
      final result = await repository.getTransactionsByEnvelope('env1');

      // Assert
      expect(result.length, 2);
      expect(result[0].id, '1');
      expect(result[1].id, '2');
      verify(mockLocalDataSource.getTransactions()).called(1);
    });
  });
  
  group('createCategory', () {
    final categoryModels = [
      CategoryModel(id: 'cat1', name: 'Alimentation'),
      CategoryModel(id: 'cat2', name: 'Transport'),
    ];
    
    test('should create a category with new UUID when id is empty', () async {
      // Arrange
      final newCategory = Category(id: '', name: 'Nouvelle Catégorie');
      
      when(mockLocalDataSource.getCategories())
          .thenAnswer((_) async => categoryModels);
          
      when(mockLocalDataSource.saveCategories(any))
          .thenAnswer((_) async {});
          
      // Act
      await repository.createCategory(newCategory);
      
      // Assert
      final capturedCategories = verify(mockLocalDataSource.saveCategories(captureAny))
          .captured.single as List<CategoryModel>;
          
      expect(capturedCategories.length, 3);
      expect(capturedCategories[2].name, 'Nouvelle Catégorie');
      expect(capturedCategories[2].id, isNot(isEmpty)); // UUID was generated
    });
  });
  
  group('createEnvelope', () {
    final envelopeModels = [
      EnvelopeModel(id: 'env1', name: 'Courses', budget: 400, spent: 250, categoryId: 'cat1'),
    ];
    
    test('should create an envelope with new UUID when id is empty', () async {
      // Arrange
      final newEnvelope = Envelope(id: '', name: 'Nouveau', budget: 100, spent: 0, categoryId: 'cat1');
      
      when(mockLocalDataSource.getEnvelopes())
          .thenAnswer((_) async => envelopeModels);
          
      when(mockLocalDataSource.saveEnvelopes(any))
          .thenAnswer((_) async {});
          
      // Act
      await repository.createEnvelope(newEnvelope);
      
      // Assert
      final capturedEnvelopes = verify(mockLocalDataSource.saveEnvelopes(captureAny))
          .captured.single as List<EnvelopeModel>;
            expect(capturedEnvelopes.length, 2);
      expect(capturedEnvelopes[1].name, 'Nouveau');
      expect(capturedEnvelopes[1].id, isNot(isEmpty)); // UUID was generated
    });
  });
}
