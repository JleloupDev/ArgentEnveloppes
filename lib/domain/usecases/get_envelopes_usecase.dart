import '../entities/envelope.dart';
import '../repositories/budget_repository.dart';

class GetEnvelopesUseCase {
  final BudgetRepository _repository;

  GetEnvelopesUseCase(this._repository);

  Future<List<Envelope>> call() async {
    return await _repository.getEnvelopes();
  }

  Stream<List<Envelope>> watch() {
    return _repository.watchEnvelopes();
  }
}
