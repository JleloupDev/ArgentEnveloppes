class Envelope {
  final String id;
  final String name;
  final double budget;
  final double spent;
  final String? categoryId;

  const Envelope({
    required this.id,
    required this.name,
    required this.budget,
    required this.spent,
    this.categoryId,
  });

  /// Calculates the remaining budget in this envelope
  double get remaining => budget - spent;

  /// Calculates the percentage of budget used
  double get percentUsed => spent / budget;

  /// Determines if the envelope is overspent
  bool get isOverspent => spent > budget;

  /// Determines if the envelope is near its budget limit
  bool get isNearLimit => percentUsed >= 0.8 && percentUsed < 1.0;
}
