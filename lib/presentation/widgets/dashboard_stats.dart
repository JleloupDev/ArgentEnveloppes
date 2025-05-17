import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../providers/envelope_provider.dart';

/// Widget pour afficher les statistiques globales du tableau de bord
class DashboardStats extends ConsumerWidget {
  const DashboardStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final envelopes = ref.watch(envelopeProvider);
    
    // Calculer les totaux
    final totalBudget = envelopes.fold<double>(0, (sum, e) => sum + e.budget);
    final totalSpent = envelopes.fold<double>(0, (sum, e) => sum + e.spent);
    final remainingBudget = totalBudget - totalSpent;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.l),
      color: AppColors.primary.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard(
            'Total des budgets',
            AppUtils.formatCurrency(totalBudget),
            Icons.account_balance_wallet,
            AppColors.primary,
          ),
          _buildStatCard(
            'Total des dépenses',
            AppUtils.formatCurrency(totalSpent),
            Icons.shopping_cart,
            AppColors.warning,
          ),
          _buildStatCard(
            'Reste disponible',
            AppUtils.formatCurrency(remainingBudget),
            Icons.savings,
            remainingBudget >= 0 ? AppColors.success : AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.m),
        width: 170,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: AppSizes.s),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.s),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Provider pour obtenir les statistiques totales du budget
final totalBudgetStatsProvider = Provider<Map<String, double>>((ref) {
  final envelopes = ref.watch(envelopeProvider);
  
  final totalBudget = envelopes.fold<double>(0, (sum, e) => sum + e.budget);
  final totalSpent = envelopes.fold<double>(0, (sum, e) => sum + e.spent);
  final totalRemaining = totalBudget - totalSpent;
  
  return {
    'budget': totalBudget,
    'spent': totalSpent,
    'remaining': totalRemaining,
  };
});
