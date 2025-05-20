import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/blue_theme.dart';  // Import du thème bleu
import 'data/datasources/local_storage_datasource.dart';
import 'data/repositories_impl/budget_repository_impl.dart';
import 'domain/repositories/budget_repository.dart';
import 'presentation/pages/dashboard_page.dart';
import 'presentation/providers/app_initialization_provider.dart';
import 'presentation/router/app_router.dart';

void main() async {
  // Assurer que les widgets sont initialisés
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser les shared preferences
  await SharedPreferences.getInstance();

  // Exécuter l'application avec Riverpod comme provider
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialiser les données de l'application au démarrage
    ref.watch(appInitializationProvider);
    
    return MaterialApp(
      title: 'Argentveloppes',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRouter.dashboard,
      routes: AppRouter.getRoutes(),
      onGenerateRoute: AppRouter.onGenerateRoute,      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: BlueTheme.primary),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: BlueTheme.appBarBackground,
          foregroundColor: BlueTheme.textLight,
        ),
        scaffoldBackgroundColor: BlueTheme.background,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.m,
            vertical: AppSizes.m,
          ),
          fillColor: BlueTheme.cardBackground,
          filled: true,
        ),
        cardTheme: CardTheme(
          color: BlueTheme.cardBackground,
          elevation: AppSizes.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: BlueTheme.primaryButtonStyle,
        ),
      ),
    );
  }
}
