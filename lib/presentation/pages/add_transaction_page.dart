import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/envelope.dart';
import '../providers/envelope_provider.dart';
import '../providers/usecase_provider.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  final String envelopeId;

  const AddTransactionPage({
    super.key,
    required this.envelopeId,
  });

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _commentController = TextEditingController(); // Contrôleur pour le champ commentaire
  
  TransactionType _type = TransactionType.expense;
  DateTime _date = DateTime.now();
  @override
  void dispose() {
    _amountController.dispose();
    _commentController.dispose(); // Libérer le contrôleur de commentaire
    super.dispose();
  }@override
  Widget build(BuildContext context) {
    // Récupérer l'enveloppe concernée
    final envelopes = ref.watch(envelopeProvider);
    final envelope = envelopes.firstWhere(
      (e) => e.id == widget.envelopeId,
      orElse: () => Envelope(
        id: '',
        name: 'Enveloppe inconnue',
        budget: 0,
        spent: 0,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle transaction'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.m),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Information sur l'enveloppe
              Card(
                elevation: AppSizes.cardElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.m),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSizes.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enveloppe',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey,
                              ),
                            ),
                            Text(
                              envelope.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Reste disponible',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.grey,
                            ),
                          ),
                          Text(
                            AppUtils.formatCurrency(envelope.remaining),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: envelope.remaining < 0 
                                  ? AppColors.error 
                                  : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppSizes.l),
              
              // Type de transaction (dépense ou revenu)
              const Text(
                'Type de transaction',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.s),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment<TransactionType>(
                    value: TransactionType.expense,
                    label: Text('Dépense'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment<TransactionType>(
                    value: TransactionType.income,
                    label: Text('Revenu'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                ],
                selected: <TransactionType>{_type},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _type = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (states) {
                      if (states.contains(WidgetState.selected)) {
                        return _type == TransactionType.expense
                            ? AppColors.error.withOpacity(0.1)
                            : AppColors.success.withOpacity(0.1);
                      }
                      return Colors.transparent;
                    },
                  ),
                  foregroundColor: WidgetStateProperty.resolveWith<Color>(
                    (states) {
                      if (states.contains(WidgetState.selected)) {
                        return _type == TransactionType.expense
                            ? AppColors.error
                            : AppColors.success;
                      }
                      return AppColors.grey;
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: AppSizes.l),
              
              // Montant
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Montant',
                  prefixIcon: Icon(Icons.euro),
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un montant';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Veuillez saisir un montant valide';
                  }
                  return null;
                },
              ),
                const SizedBox(height: AppSizes.m),
              
              // Commentaire (optionnel)
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Commentaire (optionnel)',
                  prefixIcon: Icon(Icons.comment),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: AppSizes.m),
              
              // Date
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppUtils.formatDate(_date)),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppSizes.xl),
              
              // Bouton d'enregistrement
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _type == TransactionType.expense
                        ? AppColors.error
                        : AppColors.success,
                    foregroundColor: AppColors.textLight,
                  ),
                  child: Text(
                    _type == TransactionType.expense
                        ? 'Enregistrer la dépense'
                        : 'Enregistrer le revenu',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textLight,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final amount = double.parse(_amountController.text);
        final comment = _commentController.text.trim();
        
        final transaction = Transaction(
          id: '', // L'ID sera généré dans le repository
          envelopeId: widget.envelopeId,
          amount: amount,
          type: _type,
          comment: comment.isNotEmpty ? comment : null,
          date: _date,
        );
        
        // Appeler le usecase pour ajouter la transaction
        final addTransaction = ref.read(addTransactionUseCaseProvider);
        await addTransaction(transaction);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _type == TransactionType.expense
                    ? 'Dépense ajoutée'
                    : 'Revenu ajouté',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de l\'ajout de la transaction'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
