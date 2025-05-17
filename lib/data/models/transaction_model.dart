import '../../domain/entities/transaction.dart';

class TransactionModel {
  final String id;
  final String envelopeId;
  final double amount;
  final String type; // 'expense' | 'income'
  final String description;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.envelopeId,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      envelopeId: json['envelopeId'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'envelopeId': envelopeId,
      'amount': amount,
      'type': type,
      'description': description,
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
      description: transaction.description,
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
      description: description,
      date: date,
    );
  }
}
