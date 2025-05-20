import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:argentveloppes/domain/repositories/budget_repository.dart';
import 'package:argentveloppes/domain/entities/category.dart';
import 'package:argentveloppes/domain/usecases/create_category.dart';

import 'add_transaction_test.mocks.dart';  // Re-use the mock from add_transaction_test

void main() {
  late MockBudgetRepository mockBudgetRepository;
  late CreateCategory useCase;

  setUp(() {
    mockBudgetRepository = MockBudgetRepository();
    useCase = CreateCategory(mockBudgetRepository);
  });

  final category = Category(id: '', name: 'Nouvelle catégorie');

  test('should create a new category in repository', () async {
    // Arrange
    when(mockBudgetRepository.createCategory(category))
        .thenAnswer((_) async {});

    // Act
    await useCase(category);

    // Assert
    verify(mockBudgetRepository.createCategory(category)).called(1);
    verifyNoMoreInteractions(mockBudgetRepository);
  });
}
