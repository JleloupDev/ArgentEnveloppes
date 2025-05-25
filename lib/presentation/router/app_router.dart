import 'package:argentenveloppes/presentation/pages/auth/login_page.dart';
import 'package:argentenveloppes/presentation/pages/auth/profile_page.dart';
import 'package:argentenveloppes/presentation/pages/dashboard_page.dart';
import 'package:argentenveloppes/presentation/providers/auth_provider.dart';
import 'package:argentenveloppes/presentation/router/auth_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Routeur principal de l'application
/// 
/// Configure toutes les routes de l'application et gère l'authentification
class AppRouter {
  static const String initialRoute = '/';
  static const String loginRoute = '/login';
  static const String profileRoute = '/profile';
  static const String dashboardRoute = '/dashboard'; // Ajout de la constante pour la route du dashboard
  
  /// Crée la configuration des routes
  static Map<String, WidgetBuilder> routes() {
    return {
      initialRoute: (context) => const AuthRedirector(),
      loginRoute: (context) => const LoginPage(),
      profileRoute: (context) => const AuthGuard(child: ProfilePage()),
      dashboardRoute: (context) => const AuthGuard(child: DashboardPage()), // Ajout de la route du dashboard
      // Ajoutez ici d'autres routes qui nécessitent une authentification
      // Exemple : '/dashboard': (context) => const AuthGuard(child: DashboardPage()),
    };
  }
}

/// Redirige l'utilisateur en fonction de son état d'authentification
class AuthRedirector extends ConsumerWidget {
  const AuthRedirector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      data: (user) {
        // Redirection automatique en fonction de l'état de connexion
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (user != null) {
            // Utilisateur connecté, rediriger vers la page principale de l'application
            Navigator.of(context).pushReplacementNamed(AppRouter.dashboardRoute); // Modifié pour rediriger vers le dashboard
          } else {
            // Utilisateur non connecté, rediriger vers la page de connexion
            Navigator.of(context).pushReplacementNamed(AppRouter.loginRoute);
          }
        });

        // Afficher un indicateur de chargement pendant la redirection
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // ignore: unused_result
                  ref.refresh(authStateProvider);
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}