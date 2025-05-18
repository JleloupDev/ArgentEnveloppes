import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../../domain/entities/transaction.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onDelete;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExpense = transaction.type == TransactionType.expense;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSizes.s),
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.s),
        child: Row(
          children: [
            // Icône pour le type de transaction
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isExpense ? AppColors.error.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              child: Icon(
                isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                color: isExpense ? AppColors.error : AppColors.success,
                size: 20,
              ),
            ),            const SizedBox(width: AppSizes.m),
            
            // Commentaire et date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.comment ?? 'Transaction sans description',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    AppUtils.formatDate(transaction.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            // Montant
            Text(
              (isExpense ? '- ' : '+ ') + AppUtils.formatCurrency(transaction.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isExpense ? AppColors.error : AppColors.success,
              ),
            ),
            
            // Bouton de suppression
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.grey,
                onPressed: onDelete,
                splashRadius: 20,
              ),
          ],
        ),
      ),
    );
  }
}
