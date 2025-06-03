import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/envelope.dart';
import '../../domain/entities/category.dart';
import '../providers/envelopes_provider.dart';
import '../providers/categories_provider.dart';

class CreateEnvelopePage extends ConsumerStatefulWidget {
  final String? envelopeId; // null pour création, id pour modification

  const CreateEnvelopePage({
    super.key,
    this.envelopeId,
  });

  @override
  ConsumerState<CreateEnvelopePage> createState() => _CreateEnvelopePageState();
}

class _CreateEnvelopePageState extends ConsumerState<CreateEnvelopePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  
  String? _selectedCategoryId;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.envelopeId != null;
    
    if (_isEditing) {
      // Pré-remplir les champs en mode édition
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final envelopes = ref.read(envelopesProvider);
        final envelope = envelopes.firstWhere((e) => e.id == widget.envelopeId);
        
        _nameController.text = envelope.name;
        _budgetController.text = envelope.budget.toString();
        _selectedCategoryId = envelope.categoryId;
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier l\'enveloppe' : 'Nouvelle enveloppe'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nom de l'enveloppe
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'enveloppe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un nom';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Budget maximum
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Budget maximum (€)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.euro),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un budget';
                  }
                  final budget = double.tryParse(value);
                  if (budget == null || budget <= 0) {
                    return 'Veuillez saisir un montant valide';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Sélection de catégorie
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Catégorie (optionnel)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Aucune catégorie'),
                  ),
                  ...categories.map((category) => DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.name),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
              
              const SizedBox(height: 32),
              
              // Bouton de sauvegarde
              ElevatedButton(
                onPressed: _saveEnvelope,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _isEditing ? 'Modifier l\'enveloppe' : 'Créer l\'enveloppe',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              
              if (!_isEditing) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _createNewCategory(context),
                  child: const Text('+ Créer une nouvelle catégorie'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _saveEnvelope() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final budget = double.parse(_budgetController.text);
      
      if (_isEditing) {
        // Modification d'une enveloppe existante
        final envelopes = ref.read(envelopesProvider);
        final currentEnvelope = envelopes.firstWhere((e) => e.id == widget.envelopeId);
        
        final updatedEnvelope = currentEnvelope.copyWith(
          name: name,
          budget: budget,
          categoryId: _selectedCategoryId,
        );
        
        ref.read(envelopesProvider.notifier).updateEnvelope(updatedEnvelope);
      } else {
        // Création d'une nouvelle enveloppe
        final newEnvelope = Envelope(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          budget: budget,
          spent: 0.0,
          categoryId: _selectedCategoryId,
        );
        
        ref.read(envelopesProvider.notifier).addEnvelope(newEnvelope);
      }
      
      Navigator.of(context).pop();
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'enveloppe'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette enveloppe ? '
          'Toutes les transactions associées seront également supprimées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(envelopesProvider.notifier).deleteEnvelope(widget.envelopeId!);
              Navigator.of(context).pop(); // Fermer la dialog
              Navigator.of(context).pop(); // Retourner au dashboard
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _createNewCategory(BuildContext context) {
    final categoryController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle catégorie'),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(
            labelText: 'Nom de la catégorie',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (categoryController.text.isNotEmpty) {
                final newCategory = Category(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: categoryController.text,
                );
                
                ref.read(categoriesProvider.notifier).addCategory(newCategory);
                Navigator.of(context).pop();
                
                // Sélectionner automatiquement la nouvelle catégorie
                setState(() {
                  _selectedCategoryId = newCategory.id;
                });
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}
