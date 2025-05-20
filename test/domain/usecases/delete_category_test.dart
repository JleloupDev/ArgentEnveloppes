import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:argentveloppes/domain/repositories/budget_repository.dart';
import 'package:argentveloppes/domain/usecases/delete_category.dart';

import 'add_transaction_test.mocks.dart';  // Re-use the mock from add_transaction_test

void main() {
  late MockBudgetRepository mockBudgetRepository;
  late DeleteCategory useCase;

  setUp(() {
    mockBudgetRepository = MockBudgetRepository();
    useCase = DeleteCategory(mockBudgetRepository);
  });

  test('should delete category from repository', () async {
    // Arrange
    const categoryId = '1';
    when(mockBudgetRepository.deleteCategory(categoryId))
        .thenAnswer((_) async {});

    // Act
    await useCase(categoryId);

    // Assert
    verify(mockBudgetRepository.deleteCategory(categoryId)).called(1);
    verifyNoMoreInteractions(mockBudgetRepository);
  });
}
