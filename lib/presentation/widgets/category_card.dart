import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/blue_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../core/utils/color_generator.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/envelope.dart';
import '../../domain/entities/transaction.dart';
import '../providers/envelope_provider.dart';
import '../providers/usecase_provider.dart';
import '../router/app_router.dart';

/// Widget pour afficher une carte de catégorie avec ses statistiques et ses enveloppes
class CategoryCard extends ConsumerWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddEnvelope;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.onAddEnvelope,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final envelopes = ref.watch(envelopeProvider);
    final categoryEnvelopes = envelopes
        .where((e) => e.categoryId == category.id)
        .toList();
    
    // Calculer les statistiques de cette catégorie
    final envelopeCount = categoryEnvelopes.length;
    final totalBudget = categoryEnvelopes.fold<double>(0, (sum, e) => sum + e.budget);
    final totalSpent = categoryEnvelopes.fold<double>(0, (sum, e) => sum + e.spent);
    final remainingBudget = totalBudget - totalSpent;
    
    // Obtenir une couleur unique pour cette catégorie
    final categoryColor = ColorGenerator.getColorForId(category.id);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppSizes.l),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        side: BorderSide(
          color: categoryColor,
          width: 2,
        ),
      ),
      child: Container(
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
            Container(
              padding: const EdgeInsets.all(AppSizes.m),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.borderRadius - 2),
                  topRight: Radius.circular(AppSizes.borderRadius - 2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nom de la catégorie
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
                      // Actions
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
                  
                  // Résumé des statistiques en haut
                  const SizedBox(height: AppSizes.s),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Enveloppes: $envelopeCount',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        'Budget: ${AppUtils.formatCurrency(totalBudget)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        'Dépenses: ${AppUtils.formatCurrency(totalSpent)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        'Reste: ${AppUtils.formatCurrency(remainingBudget)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: remainingBudget < 0 ? BlueTheme.error : BlueTheme.success,
                        ),
                      ),
                    ],
                  ),
                  
                  // Barre de progression
                  if (totalBudget > 0) ...[
                    const SizedBox(height: AppSizes.s),
                    LinearProgressIndicator(
                      value: (totalSpent / totalBudget).clamp(0.0, 1.0),
                      backgroundColor: BlueTheme.primaryLight.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        totalSpent >= totalBudget ? BlueTheme.error : 
                        totalSpent >= (totalBudget * 0.8) ? BlueTheme.warning : 
                        BlueTheme.primary,
                      ),
                      minHeight: 4,
                    ),
                  ],
                ],
              ),
            ),
            
            // Enveloppes de la catégorie
            if (categoryEnvelopes.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSizes.m),
                child: _buildEmptyEnvelopesState(context, onAddEnvelope),
              )
            else
              Padding(
                padding: const EdgeInsets.all(AppSizes.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Enveloppes dans cette catégorie',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: onAddEnvelope,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Ajouter'),
                          style: TextButton.styleFrom(
                            foregroundColor: BlueTheme.primary,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xs),
                    ...categoryEnvelopes.map((envelope) => 
                      _buildEnvelopeItem(context, envelope)
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyEnvelopesState(BuildContext context, VoidCallback onAddEnvelope) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 32,
            color: AppColors.grey,
          ),
          const SizedBox(height: AppSizes.s),
          const Text(
            'Aucune enveloppe dans cette catégorie',
            style: TextStyle(color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.s),
          ElevatedButton.icon(
            onPressed: onAddEnvelope,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Ajouter une enveloppe'),
            style: ElevatedButton.styleFrom(
              backgroundColor: BlueTheme.primary,
              foregroundColor: BlueTheme.textLight,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.xs),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour afficher une enveloppe dans la catégorie
  Widget _buildEnvelopeItem(BuildContext context, Envelope envelope) {
    // Calculer le pourcentage utilisé et déterminer la couleur
    final percentUsed = envelope.budget > 0 
        ? (envelope.spent / envelope.budget).clamp(0.0, 1.0)
        : 0.0;

    Color progressColor;
    if (percentUsed >= 0.8) {
      progressColor = percentUsed >= 1 ? BlueTheme.error : BlueTheme.warning;
    } else {
      progressColor = BlueTheme.primary;
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: AppSizes.s),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius / 2),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRouter.envelopeDetail,
          arguments: envelope.id,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius / 2),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom de l'enveloppe
              Text(
                envelope.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: AppSizes.xs),
              
              // Barre de progression
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius / 2),
                child: LinearProgressIndicator(
                  value: percentUsed,
                  backgroundColor: BlueTheme.primaryLight.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 6,
                ),
              ),
              
              const SizedBox(height: AppSizes.xs),
              
              // Montants
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${AppUtils.formatCurrency(envelope.spent)} / ${AppUtils.formatCurrency(envelope.budget)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: envelope.spent > envelope.budget ? BlueTheme.error : null,
                    ),
                  ),
                  Text(
                    'Reste: ${AppUtils.formatCurrency(envelope.remaining)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: envelope.remaining < 0 ? BlueTheme.error : BlueTheme.success,
                    ),
                  ),
                ],
              ),
              
              // Bouton d'ajout rapide
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _showQuickAddDialog(context, envelope),
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Ajouter une dépense', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: BlueTheme.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
    // Dialogue pour ajouter rapidement une transaction
  void _showQuickAddDialog(BuildContext context, Envelope envelope) {
    final amountController = TextEditingController();
    final commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter une dépense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enveloppe: ${envelope.name}'),
              const SizedBox(height: AppSizes.m),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Montant',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.euro),
                ),
                autofocus: true,
              ),
              const SizedBox(height: AppSizes.m),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Commentaire (optionnel)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.comment),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            Consumer(
              builder: (context, ref, child) {
                return TextButton(
                  onPressed: () async {
                    final amountText = amountController.text.replaceAll(',', '.').trim();
                    if (amountText.isNotEmpty) {
                      try {
                        final amount = double.parse(amountText);
                        if (amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Le montant doit être supérieur à 0')),
                          );
                          return;
                        }
                          // Récupérer le commentaire (s'il est fourni)
                        final comment = commentController.text.trim();
                          // Créer la nouvelle transaction
                        final newTransaction = Transaction(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          envelopeId: envelope.id,
                          amount: amount,
                          type: TransactionType.expense,
                          comment: comment.isNotEmpty ? comment : 'Ajout rapide',
                          date: DateTime.now(),
                        );
                          // Utiliser le use case pour ajouter la transaction
                        final addTransactionUseCase = ref.read(addTransactionUseCaseProvider);
                        await addTransactionUseCase.call(newTransaction);
                        
                        // Mettre à jour l'enveloppe avec la nouvelle dépense
                        final updatedEnvelope = Envelope(
                          id: envelope.id,
                          name: envelope.name,
                          budget: envelope.budget,
                          spent: envelope.spent + amount,
                          categoryId: envelope.categoryId,
                        );
                        ref.read(envelopeProvider.notifier).updateEnvelope(updatedEnvelope);
                        
                        // Fermer le dialogue
                        Navigator.pop(context);
                        
                        // Message de confirmation
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Dépense de ${AppUtils.formatCurrency(amount)} ajoutée')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Montant invalide')),
                        );
                      }
                    }
                  },
                  child: const Text('Ajouter'),
                );
              }
            ),
          ],
        );
      },
    );
  }
}
