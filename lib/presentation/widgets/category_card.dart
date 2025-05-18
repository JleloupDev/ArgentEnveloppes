import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../../core/utils/color_generator.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/envelope.dart';
import '../providers/envelope_provider.dart';

/// Widget pour afficher une carte de catégorie avec ses statistiques
class CategoryCard extends ConsumerWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final envelopes = ref.watch(envelopeProvider);
    final categoryEnvelopes = envelopes
        .where((e) => e.categoryId == category.id)
        .toList();
    
    // Calculer les statistiques
    final envelopeCount = categoryEnvelopes.length;
    final totalBudget = categoryEnvelopes.fold<double>(0, (sum, e) => sum + e.budget);
    final totalSpent = categoryEnvelopes.fold<double>(0, (sum, e) => sum + e.spent);
    final remainingBudget = totalBudget - totalSpent;
      // Obtenir une couleur unique pour cette catégorie
    final categoryColor = ColorGenerator.getColorForId(category.id);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppSizes.s),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        side: BorderSide(
          color: categoryColor,
          width: 2,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.m),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius - 2),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              categoryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec nom et actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.only(right: AppSizes.xs),
                      ),
                      Expanded(
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onEdit,
                      tooltip: 'Modifier',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(AppSizes.xs),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: onDelete,
                      tooltip: 'Supprimer',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(AppSizes.xs),
                    ),
                  ],
                ),
              ],
            ),
            
            // Statistiques de la catégorie
            const SizedBox(height: AppSizes.s),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2,
                mainAxisSpacing: AppSizes.s,
                crossAxisSpacing: AppSizes.s,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStat('Enveloppes', '$envelopeCount'),
                  _buildStat('Budget', AppUtils.formatCurrency(totalBudget)),
                  _buildStat('Dépenses', AppUtils.formatCurrency(totalSpent)),
                  _buildStat(
                    'Disponible', 
                    AppUtils.formatCurrency(remainingBudget),
                    remainingBudget < 0 ? AppColors.error : AppColors.success,
                  ),
                ],
              ),
            ),
            
            if (totalBudget > 0) ...[
              const SizedBox(height: AppSizes.s),
              // Barre de progression
              LinearProgressIndicator(
                value: (totalSpent / totalBudget).clamp(0.0, 1.0),
                backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  totalSpent >= totalBudget ? AppColors.error : 
                  totalSpent >= (totalBudget * 0.8) ? AppColors.warning : 
                  AppColors.primary,
                ),
                minHeight: 4,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, [Color? valueColor]) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xs),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.s),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
