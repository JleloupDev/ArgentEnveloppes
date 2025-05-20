import '../entities/category.dart';
import '../entities/envelope.dart';
import '../repositories/budget_repository.dart';

class DashboardData {
  final List<Envelope> envelopes;
  final List<Category> categories;
  final double totalBudget;
  final double totalSpent;
  final double totalRemaining;
  
  DashboardData({
    required this.envelopes,
    required this.categories,
    required this.totalBudget,
    required this.totalSpent,
    required this.totalRemaining,
  });
}

class GetDashboardData {
  final BudgetRepository repository;

  GetDashboardData(this.repository);

  Future<DashboardData> call() async {
    final envelopes = await repository.getAllEnvelopes();
    final categories = await repository.getCategories();
    
    final totalBudget = envelopes.fold<double>(0, (sum, envelope) => sum + envelope.budget);
    final totalSpent = envelopes.fold<double>(0, (sum, envelope) => sum + envelope.spent);
    final totalRemaining = totalBudget - totalSpent;
    
    return DashboardData(
      envelopes: envelopes,
      categories: categories,
      totalBudget: totalBudget,
      totalSpent: totalSpent,
      totalRemaining: totalRemaining,
    );
  }
}
