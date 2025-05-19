import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:argentveloppes/domain/repositories/budget_repository.dart';
import 'package:argentveloppes/domain/entities/category.dart';
import 'package:argentveloppes/domain/usecases/get_categories.dart';

import 'add_transaction_test.mocks.dart';  // Re-use the mock from add_transaction_test

void main() {
  late MockBudgetRepository mockBudgetRepository;
  late GetCategories useCase;

  setUp(() {
    mockBudgetRepository = MockBudgetRepository();
    useCase = GetCategories(mockBudgetRepository);
  });

  const testCategories = [
    Category(id: '1', name: 'Alimentation'),
    Category(id: '2', name: 'Transport'),
    Category(id: '3', name: 'Logement')
  ];

  test('should get categories from repository', () async {
    // Arrange
    when(mockBudgetRepository.getCategories())
        .thenAnswer((_) async => testCategories);

    // Act
    final result = await useCase();

    // Assert
    expect(result, testCategories);
    verify(mockBudgetRepository.getCategories()).called(1);
    verifyNoMoreInteractions(mockBudgetRepository);
  });

  test('should return empty list when no categories exist', () async {
    // Arrange
    when(mockBudgetRepository.getCategories())
        .thenAnswer((_) async => []);

    // Act
    final result = await useCase();

    // Assert
    expect(result, []);
    verify(mockBudgetRepository.getCategories()).called(1);
    verifyNoMoreInteractions(mockBudgetRepository);
  });
}
