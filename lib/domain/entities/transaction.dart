enum TransactionType { expense, income }

class Transaction {
  final String id;
  final String envelopeId;
  final double amount;
  final TransactionType type;
  final String? comment; // Commentaire sur la transaction
  final DateTime date;

  const Transaction({
    required this.id,
    required this.envelopeId,
    required this.amount,
    required this.type,
    this.comment,
    required this.date,
  });

  /// Returns the amount as a positive or negative value based on transaction type
  double get signedAmount => type == TransactionType.expense ? -amount : amount;
}
