import '../../domain/entities/transaction.dart';

class TransactionModel {
  final String id;
  final String envelopeId;
  final double amount;
  final String type; // 'expense' | 'income'
  final String? comment;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.envelopeId,
    required this.amount,
    required this.type,
    this.comment,
    required this.date,
  });
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      envelopeId: json['envelopeId'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      comment: json['comment'] as String?,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'envelopeId': envelopeId,
      'amount': amount,
      'type': type,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }
  // Convert model to domain entity
  factory TransactionModel.fromDomain(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      envelopeId: transaction.envelopeId,
      amount: transaction.amount,
      type: transaction.type == TransactionType.expense ? 'expense' : 'income',
      comment: transaction.comment,
      date: transaction.date,
    );
  }

  // Convert to domain entity
  Transaction toDomain() {
    return Transaction(
      id: id,
      envelopeId: envelopeId,
      amount: amount,
      type: type == 'expense' ? TransactionType.expense : TransactionType.income,
      comment: comment,
      date: date,
    );
  }
}
