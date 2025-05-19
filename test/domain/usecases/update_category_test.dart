import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:argentveloppes/domain/repositories/budget_repository.dart';
import 'package:argentveloppes/domain/entities/category.dart';
import 'package:argentveloppes/domain/usecases/update_category.dart';

import 'add_transaction_test.mocks.dart';  // Re-use the mock from add_transaction_test

void main() {
  late MockBudgetRepository mockBudgetRepository;
  late UpdateCategory useCase;

  setUp(() {
    mockBudgetRepository = MockBudgetRepository();
    useCase = UpdateCategory(mockBudgetRepository);
  });

  const category = Category(
    id: '1',
    name: 'Alimentation Modifiée',
  );

  const originalCategories = [
    Category(id: '1', name: 'Alimentation'),
    Category(id: '2', name: 'Transport'),
  ];

  test('should update a category in repository', () async {
    // Arrange
    when(mockBudgetRepository.getCategories())
        .thenAnswer((_) async => originalCategories);
    when(mockBudgetRepository.deleteCategory(category.id))
        .thenAnswer((_) async {});
    when(mockBudgetRepository.createCategory(category))
        .thenAnswer((_) async {});

    // Act
    await useCase(category);

    // Assert
    verify(mockBudgetRepository.getCategories()).called(1);
    verify(mockBudgetRepository.deleteCategory(category.id)).called(1);
    verify(mockBudgetRepository.createCategory(category)).called(1);
    verifyNoMoreInteractions(mockBudgetRepository);
  });

  test('should throw exception when category does not exist', () async {
    // Arrange
    const nonExistentCategory = Category(
      id: 'non-existent',
      name: 'Non-existent Category',
    );

    when(mockBudgetRepository.getCategories())
        .thenAnswer((_) async => originalCategories);

    // Act and Assert
    expect(
      () => useCase(nonExistentCategory),
      throwsA(isA<Exception>().having(
        (e) => e.toString(),
        'message',
        contains('Catégorie non trouvée'),
      )),
    );

    verify(mockBudgetRepository.getCategories()).called(1);
    verifyNoMoreInteractions(mockBudgetRepository);
  });
}
