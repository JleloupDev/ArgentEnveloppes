import '../repositories/budget_repository.dart';

class DeleteEnvelope {
  final BudgetRepository repository;

  DeleteEnvelope(this.repository);

  Future<void> call(String envelopeId) {
    return repository.deleteEnvelope(envelopeId);
  }
}
