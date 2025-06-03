import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/envelope.dart';
import '../../domain/entities/transaction.dart';
import '../providers/envelopes_provider.dart';
import '../providers/transactions_provider.dart';

class EnvelopeDetailPage extends ConsumerWidget {
  final String envelopeId;

  const EnvelopeDetailPage({
    super.key,
    required this.envelopeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final envelopes = ref.watch(envelopesProvider);
    final envelope = envelopes.firstWhere((e) => e.id == envelopeId);
    final transactions = ref.watch(transactionsProvider.notifier).getTransactionsForEnvelope(envelopeId);

    return Scaffold(
      appBar: AppBar(
        title: Text(envelope.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Modifier l'enveloppe
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec les détails de l'enveloppe
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                _buildProgressIndicator(envelope),
                const SizedBox(height: 16),
                _buildBudgetInfo(envelope),
              ],
            ),
          ),
          
          // Actions rapides
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddTransactionDialog(context, ref, envelope, TransactionType.expense),
                    icon: const Icon(Icons.remove),
                    label: const Text('Ajouter dépense'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[100],
                      foregroundColor: Colors.red[800],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddTransactionDialog(context, ref, envelope, TransactionType.income),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter revenu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[100],
                      foregroundColor: Colors.green[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des transactions
          Expanded(
            child: _buildTransactionsList(transactions, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(Envelope envelope) {
    Color statusColor;
    switch (envelope.status) {
      case EnvelopeStatus.good:
        statusColor = Colors.green;
        break;
      case EnvelopeStatus.warning:
        statusColor = Colors.orange;
        break;
      case EnvelopeStatus.exceeded:
        statusColor = Colors.red;
        break;
    }

    return Column(
      children: [
        CircularProgressIndicator(
          value: (envelope.consumptionPercentage / 100).clamp(0.0, 1.0),
          strokeWidth: 8,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
        ),
        const SizedBox(height: 8),
        Text(
          '${envelope.consumptionPercentage.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetInfo(Envelope envelope) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildBudgetItem('Budget', '${envelope.budget.toStringAsFixed(2)} €', Colors.blue),
        _buildBudgetItem('Dépensé', '${envelope.spent.toStringAsFixed(2)} €', Colors.red),
        _buildBudgetItem('Reste', '${envelope.remaining.toStringAsFixed(2)} €', 
          envelope.remaining >= 0 ? Colors.green : Colors.red),
      ],
    );
  }

  Widget _buildBudgetItem(String label, String amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(List<Transaction> transactions, WidgetRef ref) {
    if (transactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune transaction',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Ajoutez votre première transaction',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionTile(transaction, ref);
      },
    );
  }

  Widget _buildTransactionTile(Transaction transaction, WidgetRef ref) {
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? Colors.red : Colors.green;
    final icon = isExpense ? Icons.remove : Icons.add;

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          '${isExpense ? '-' : '+'}${transaction.amount.toStringAsFixed(2)} €',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.comment != null && transaction.comment!.isNotEmpty)
              Text(transaction.comment!),
            Text(
              _formatDate(transaction.date),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.grey),
          onPressed: () => _confirmDeleteTransaction(ref, transaction),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Aujourd\'hui';
    if (difference == 1) return 'Hier';
    if (difference < 7) return 'Il y a $difference jours';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref, Envelope envelope, TransactionType type) {
    final amountController = TextEditingController();
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type == TransactionType.expense ? 'Ajouter une dépense' : 'Ajouter un revenu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Montant (€)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Commentaire (optionnel)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                final transaction = Transaction(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  envelopeId: envelope.id,
                  amount: amount,
                  type: type,
                  comment: commentController.text.isEmpty ? null : commentController.text,
                  date: DateTime.now(),
                );
                
                ref.read(transactionsProvider.notifier).addTransaction(transaction);
                ref.read(envelopesProvider.notifier).addTransaction(
                  envelope.id, 
                  amount, 
                  type == TransactionType.expense,
                );
                
                Navigator.of(context).pop();
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTransaction(WidgetRef ref, Transaction transaction) {
    // Implémenter la confirmation de suppression
    ref.read(transactionsProvider.notifier).deleteTransaction(transaction.id);
    ref.read(envelopesProvider.notifier).addTransaction(
      transaction.envelopeId,
      transaction.amount,
      transaction.type == TransactionType.income, // Inverse pour annuler
    );
  }
}
