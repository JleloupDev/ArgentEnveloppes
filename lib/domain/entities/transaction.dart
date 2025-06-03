class Transaction {
  final String id;
  final String envelopeId;
  final double amount;
  final TransactionType type;
  final String? comment;
  final DateTime date;

  Transaction({
    required this.id,
    required this.envelopeId,
    required this.amount,
    required this.type,
    this.comment,
    required this.date,
  });

  Transaction copyWith({
    String? id,
    String? envelopeId,
    double? amount,
    TransactionType? type,
    String? comment,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      envelopeId: envelopeId ?? this.envelopeId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      comment: comment ?? this.comment,
      date: date ?? this.date,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.envelopeId == envelopeId &&
        other.amount == amount &&
        other.type == type &&
        other.comment == comment &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        envelopeId.hashCode ^
        amount.hashCode ^
        type.hashCode ^
        comment.hashCode ^
        date.hashCode;
  }

  @override
  String toString() {
    return 'Transaction(id: $id, envelopeId: $envelopeId, amount: $amount, type: $type, comment: $comment, date: $date)';
  }
}

enum TransactionType {
  expense, // Dépense
  income   // Revenu
}