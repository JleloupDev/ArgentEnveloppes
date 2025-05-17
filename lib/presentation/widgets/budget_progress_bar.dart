import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';

class BudgetProgressBar extends StatelessWidget {
  final double spent;
  final double budget;
  final double height;
  final bool showPercentage;
  final Color backgroundColor;

  const BudgetProgressBar({
    super.key,
    required this.spent,
    required this.budget,
    this.height = 10.0,
    this.showPercentage = false,
    this.backgroundColor = Colors.black12,
  });

  @override
  Widget build(BuildContext context) {
    // Calculer le pourcentage de progression
    double percentage = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    double exceededPercentage = budget > 0 ? (spent / budget).clamp(1.0, double.infinity) - 1.0 : 0.0;
    bool hasExceeded = spent > budget;
    
    // Déterminer la couleur de la barre en fonction du pourcentage
    Color progressColor;
    if (percentage >= 0.8 || hasExceeded) {
      progressColor = hasExceeded ? AppColors.error : AppColors.warning;
    } else {
      progressColor = AppColors.primary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius / 2),
          child: Container(
            height: height,
            color: backgroundColor,
            child: Row(
              children: [
                // Barre de progression principale
                Flexible(
                  flex: (percentage * 100).toInt(),
                  child: Container(
                    color: progressColor,
                  ),
                ),
                
                // Espace restant (si pas dépassé)
                if (!hasExceeded) 
                  Flexible(
                    flex: ((1 - percentage) * 100).toInt(),
                    child: const SizedBox(),
                  ),
              ],
            ),
          ),
        ),
        
        // Afficher le pourcentage si demandé
        if (showPercentage) 
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hasExceeded 
                    ? '${AppUtils.formatPercentage(1.0)} + ${AppUtils.formatPercentage(exceededPercentage)}' 
                    : AppUtils.formatPercentage(percentage),
                  style: TextStyle(
                    fontSize: 12,
                    color: progressColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${AppUtils.formatCurrency(spent)} / ${AppUtils.formatCurrency(budget)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
