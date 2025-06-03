import '../../domain/entities/envelope.dart';

class EnvelopeModel {
  final String id;
  final String name;
  final double budget;
  final double spent;
  final String? categoryId;

  EnvelopeModel({
    required this.id,
    required this.name,
    required this.budget,
    required this.spent,
    this.categoryId,
  });

  factory EnvelopeModel.fromJson(Map<String, dynamic> json) {
    return EnvelopeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      budget: (json['budget'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
      categoryId: json['categoryId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'budget': budget,
      'spent': spent,
      'categoryId': categoryId,
    };
  }

  // Convert model to domain entity
  factory EnvelopeModel.fromDomain(Envelope envelope) {
    return EnvelopeModel(
      id: envelope.id,
      name: envelope.name,
      budget: envelope.budget,
      spent: envelope.spent,
      categoryId: envelope.categoryId,
    );
  }

  // Convert to domain entity
  Envelope toDomain() {
    return Envelope(
      id: id,
      name: name,
      budget: budget,
      spent: spent,
      categoryId: categoryId,
    );
  }
}
