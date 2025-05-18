import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import '../providers/envelope_provider.dart';
import '../providers/usecase_provider.dart';

/// Provider pour initialiser les données de l'application au démarrage
final appInitializationProvider = FutureProvider<void>((ref) async {
  // Récupérer les catégories depuis le repository
  final getCategories = ref.watch(getCategoriesUseCaseProvider);
  final categories = await getCategories();
  
  // Mettre à jour le provider de catégories
  ref.read(categoryProvider.notifier).setCategories(categories);
  
  // Récupérer les enveloppes depuis le repository
  final getAllEnvelopes = ref.watch(getAllEnvelopesUseCaseProvider);
  final envelopes = await getAllEnvelopes();
  
  // Mettre à jour le provider d'enveloppes
  ref.read(envelopeProvider.notifier).setEnvelopes(envelopes);
  
  return;
});

/// Provider pour un use case de récupération de toutes les enveloppes
final getAllEnvelopesUseCaseProvider = Provider((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return repository.getAllEnvelopes;
});
