import '../repositories/budget_repository.dart';

class DeleteEnvelopeUseCase {
  final BudgetRepository _repository;

  DeleteEnvelopeUseCase(this._repository);

  Future<void> call(String envelopeId) async {
    if (envelopeId.isEmpty) {
      throw ArgumentError('Envelope ID cannot be empty');
    }
    
    await _repository.deleteEnvelope(envelopeId);
  }
}
