class Envelope {
  final String id;
  final String name;
  final double budget;
  final double spent;
  final String? categoryId;

  Envelope({
    required this.id,
    required this.name,
    required this.budget,
    required this.spent,
    this.categoryId,
  });

  /// Calcule le montant restant dans l'enveloppe
  double get remaining => budget - spent;

  /// Calcule le pourcentage de consommation du budget
  double get consumptionPercentage => budget > 0 ? (spent / budget) * 100 : 0;

  /// Détermine l'état visuel de l'enveloppe selon la consommation
  EnvelopeStatus get status {
    if (consumptionPercentage < 80) return EnvelopeStatus.good;
    if (consumptionPercentage <= 100) return EnvelopeStatus.warning;
    return EnvelopeStatus.exceeded;
  }

  Envelope copyWith({
    String? id,
    String? name,
    double? budget,
    double? spent,
    String? categoryId,
  }) {
    return Envelope(
      id: id ?? this.id,
      name: name ?? this.name,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Envelope &&
        other.id == id &&
        other.name == name &&
        other.budget == budget &&
        other.spent == spent &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        budget.hashCode ^
        spent.hashCode ^
        categoryId.hashCode;
  }

  @override
  String toString() {
    return 'Envelope(id: $id, name: $name, budget: $budget, spent: $spent, categoryId: $categoryId)';
  }
}

enum EnvelopeStatus {
  good,    // < 80%
  warning, // 80-100%
  exceeded // > 100%
}
