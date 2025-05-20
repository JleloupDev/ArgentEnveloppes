import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../../domain/entities/envelope.dart';
import '../../domain/entities/transaction.dart';
import '../providers/usecase_provider.dart';

class EnvelopeCardWithQuickAdd extends ConsumerStatefulWidget {
  final Envelope envelope;
  final String? categoryName;
  final VoidCallback onTap;

  const EnvelopeCardWithQuickAdd({
    Key? key,
    required this.envelope,
    this.categoryName,
    required this.onTap,
  }) : super(key: key);

  @override
  ConsumerState<EnvelopeCardWithQuickAdd> createState() => _EnvelopeCardWithQuickAddState();
}

class _EnvelopeCardWithQuickAddState extends ConsumerState<EnvelopeCardWithQuickAdd> {
  final TextEditingController _amountController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final envelope = widget.envelope;
    
    // Calculer le pourcentage utilisé et déterminer la couleur
    final percentUsed = envelope.budget > 0 
        ? (envelope.spent / envelope.budget).clamp(0.0, 1.0) 
        : 0.0;
    
    final progressColor = envelope.isOverspent
        ? AppColors.error
        : envelope.isNearLimit
            ? AppColors.warning
            : AppColors.primary;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppSizes.m),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec nom et catégorie
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      envelope.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.categoryName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.s, 
                        vertical: AppSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.xs),
                      ),
                      child: Text(
                        widget.categoryName!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: AppSizes.m),
              
              // Montants et barre de progression
              Row(
                children: [
                  Text(
                    AppUtils.formatCurrency(envelope.spent),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' / ${AppUtils.formatCurrency(envelope.budget)}',
                    style: const TextStyle(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSizes.xs),
              
              // Barre de progression
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.xs),
                child: LinearProgressIndicator(
                  value: percentUsed,
                  backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 6,
                ),
              ),
              
              const SizedBox(height: AppSizes.s),
              
              // Montant restant
              Row(
                children: [
                  const Text('Reste : '),
                  Text(
                    AppUtils.formatCurrency(envelope.remaining),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: envelope.isOverspent
                          ? AppColors.error
                          : AppColors.success,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSizes.m),
              
              // Transaction rapide et bouton détails
              Row(
                children: [
                  // Champ montant
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSizes.s, 
                          vertical: AppSizes.s,
                        ),
                        hintText: 'Montant',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addQuickTransaction(),
                    ),
                  ),
                  
                  // Bouton ajouter
                  IconButton(
                    icon: isLoading
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add),
                    onPressed: isLoading ? null : _addQuickTransaction,
                    color: AppColors.primary,
                  ),
                  
                  // Bouton détails
                  TextButton.icon(
                    onPressed: widget.onTap,
                    icon: const Icon(
                      Icons.arrow_forward,
                      size: 16,
                    ),
                    label: const Text('Détails'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _addQuickTransaction() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return;
    
    double? amount = double.tryParse(amountText.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant invalide')),
      );
      return;
    }
    
    setState(() => isLoading = true);
    
    try {      // Création d'une transaction rapide (dépense uniquement)
      final transaction = Transaction(
        id: '', // ID sera généré par le repository
        envelopeId: widget.envelope.id,
        amount: amount,
        type: TransactionType.expense,
        comment: 'Transaction rapide',
        date: DateTime.now(),
      );
      
      // Utiliser le use case pour ajouter la transaction
      final addTransaction = ref.read(addTransactionUseCaseProvider);
      await addTransaction(transaction);
      
      // Vider le champ et afficher confirmation
      _amountController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppUtils.formatCurrency(amount)} ajouté')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'ajout de la transaction')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
}
