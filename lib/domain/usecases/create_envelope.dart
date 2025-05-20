import '../entities/envelope.dart';
import '../repositories/budget_repository.dart';

class CreateEnvelope {
  final BudgetRepository repository;

  CreateEnvelope(this.repository);

  Future<void> call(Envelope envelope) {
    return repository.createEnvelope(envelope);
  }
}
