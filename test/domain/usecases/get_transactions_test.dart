import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:argentveloppes/domain/repositories/budget_repository.dart';
import 'package:argentveloppes/domain/entities/transaction.dart';
import 'package:argentveloppes/domain/usecases/get_transactions.dart';

import 'add_transaction_test.mocks.dart'; // Re-use the mock from add_transaction_test

void main() {
  late MockBudgetRepository mockBudgetRepository;
  late GetTransactions useCase;

  setUp(() {
    mockBudgetRepository = MockBudgetRepository();
    useCase = GetTransactions(mockBudgetRepository);
  });

  final today = DateTime.now();
  final transactions = [
    Transaction(
      id: '1',
      envelopeId: 'env1',
      amount: 50.0,
      type: TransactionType.expense,
      comment: 'Courses au supermarché',
      date: today,
    ),
    Transaction(
      id: '2',
      envelopeId: 'env1',
      amount: 35.0,
      type: TransactionType.expense,
      comment: 'Marché',
      date: today.subtract(const Duration(days: 3)),
    ),
  ];

  test('should get transactions for a specific envelope from repository', () async {
    // Arrange
    const envelopeId = 'env1';
    when(mockBudgetRepository.getTransactionsByEnvelope(envelopeId))
        .thenAnswer((_) async => transactions);

    // Act
    final result = await useCase(envelopeId);

    // Assert
    expect(result, transactions);
    verify(mockBudgetRepository.getTransactionsByEnvelope(envelopeId)).called(1);
    verifyNoMoreInteractions(mockBudgetRepository);
  });
}
