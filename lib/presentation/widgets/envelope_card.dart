import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/blue_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../domain/entities/envelope.dart';

class EnvelopeCard extends ConsumerStatefulWidget {
  final Envelope envelope;
  final String? categoryName;
  final VoidCallback onTap;
  final VoidCallback? onAddTransaction;

  const EnvelopeCard({
    super.key,
    required this.envelope,
    this.categoryName,
    required this.onTap,
    this.onAddTransaction,
  });
  
  @override
  ConsumerState<EnvelopeCard> createState() => _EnvelopeCardState();
}

class _EnvelopeCardState extends ConsumerState<EnvelopeCard> {
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
    
    return Card(
      elevation: AppSizes.cardElevation,
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.categoryName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.s,
                        vertical: AppSizes.xs,
                      ),                      decoration: BoxDecoration(
                        color: BlueTheme.primaryLight,
                        borderRadius: BorderRadius.circular(AppSizes.s),
                      ),
                      child: Text(
                        widget.categoryName!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: BlueTheme.primaryDark,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: AppSizes.m),
              
              // Barre de progression
              _buildProgressBar(),
              
              const SizedBox(height: AppSizes.m),
              
              // Montants
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [                  _buildAmountDisplay(
                    'Dépensé',
                    envelope.spent,
                    envelope.spent > envelope.budget ? BlueTheme.error : null,
                  ),
                  _buildAmountDisplay('Budget', envelope.budget),
                  _buildAmountDisplay(
                    'Reste',
                    envelope.remaining,
                    envelope.remaining < 0 ? BlueTheme.error : BlueTheme.success,
                  ),
                ],
              ),
              
              // Bouton d'ajout de transaction rapide
              if (widget.onAddTransaction != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSizes.m),
                    child: OutlinedButton.icon(
                      onPressed: widget.onAddTransaction,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Ajouter une dépense'),                      style: OutlinedButton.styleFrom(
                        foregroundColor: BlueTheme.primary,
                        side: const BorderSide(color: BlueTheme.primary),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.m,
                          vertical: AppSizes.s,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    double percentage = widget.envelope.budget > 0 ? widget.envelope.spent / widget.envelope.budget : 0;
      Color progressColor;
    if (percentage >= 0.8) {
      progressColor = percentage >= 1 ? BlueTheme.error : BlueTheme.warning;
    } else {
      progressColor = BlueTheme.primary;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius / 2),
          child: LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            backgroundColor: BlueTheme.primaryLight.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountDisplay(String label, double amount, [Color? valueColor]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(          label,
          style: TextStyle(
            fontSize: 12,
            color: BlueTheme.textDark.withOpacity(0.6),
          ),
        ),
        Text(
          AppUtils.formatCurrency(amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
