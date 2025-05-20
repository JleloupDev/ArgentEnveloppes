import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:argentveloppes/domain/repositories/budget_repository.dart';
import 'package:argentveloppes/domain/entities/transaction.dart';
import 'package:argentveloppes/domain/usecases/add_transaction.dart';

import 'add_transaction_test.mocks.dart';

// Generate a MockBudgetRepository using Mockito.
@GenerateMocks([BudgetRepository])
void main() {
  late MockBudgetRepository mockBudgetRepository;
  late AddTransaction useCase;

  setUp(() {
    mockBudgetRepository = MockBudgetRepository();
    useCase = AddTransaction(mockBudgetRepository);
  });

  final transaction = Transaction(
    id: '1',
    envelopeId: 'env1',
    amount: 50.0,
    type: TransactionType.expense,
    comment: 'Courses au supermarché',
    date: DateTime.now(),
  );

  test('should add a transaction to repository', () async {
    // Arrange
    when(mockBudgetRepository.addTransaction(transaction))
        .thenAnswer((_) async {});

    // Act
    await useCase(transaction);

    // Assert
    verify(mockBudgetRepository.addTransaction(transaction)).called(1);
    verifyNoMoreInteractions(mockBudgetRepository);
  });
}
