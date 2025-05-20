import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:argentveloppes/domain/repositories/budget_repository.dart';
import 'package:argentveloppes/domain/entities/envelope.dart';
import 'package:argentveloppes/domain/usecases/create_envelope.dart';

import 'add_transaction_test.mocks.dart';  // Re-use the mock from add_transaction_test

void main() {
  late MockBudgetRepository mockBudgetRepository;
  late CreateEnvelope useCase;

  setUp(() {
    mockBudgetRepository = MockBudgetRepository();
    useCase = CreateEnvelope(mockBudgetRepository);
  });

  test('should create a new envelope in repository', () async {
    // Given
    const envelope = Envelope(
      id: '',  // Empty ID will be replaced with a UUID in repository
      name: 'Courses',
      budget: 500.0,
      spent: 0.0,
      categoryId: 'cat1',
    );

    // When
    when(mockBudgetRepository.createEnvelope(envelope))
        .thenAnswer((_) async {});

    // Act
    await useCase(envelope);

    // Assert
    verify(mockBudgetRepository.createEnvelope(envelope)).called(1);
    verifyNoMoreInteractions(mockBudgetRepository);
  });
}
