import '../entities/envelope.dart';
import '../repositories/budget_repository.dart';

class UpdateEnvelopeUseCase {
  final BudgetRepository _repository;

  UpdateEnvelopeUseCase(this._repository);

  Future<void> call(Envelope envelope) async {
    // Validate envelope data
    if (envelope.name.isEmpty) {
      throw ArgumentError('Envelope name cannot be empty');
    }
    if (envelope.budget <= 0) {
      throw ArgumentError('Envelope budget must be positive');
    }
    
    await _repository.updateEnvelope(envelope);
  }
}
