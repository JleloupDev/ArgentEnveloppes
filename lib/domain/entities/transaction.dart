enum TransactionType { expense, income }

class Transaction {
  final String id;
  final String envelopeId;
  final double amount;
  final TransactionType type;
  final String description;
  final DateTime date;

  const Transaction({
    required this.id,
    required this.envelopeId,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
  });

  /// Returns the amount as a positive or negative value based on transaction type
  double get signedAmount => type == TransactionType.expense ? -amount : amount;
}
