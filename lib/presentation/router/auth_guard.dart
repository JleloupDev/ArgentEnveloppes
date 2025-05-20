import 'package:argentenveloppes/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Un widget qui redirige vers la page de connexion si l'utilisateur n'est pas connecté.
/// 
/// Utilise le `isUserLoggedInProvider` pour déterminer si l'utilisateur est connecté.
class AuthGuard extends ConsumerWidget {
  final Widget child;
  final String loginRoute;

  const AuthGuard({
    super.key,
    required this.child,
    this.loginRoute = '/login',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);
    
    return authStateAsync.when(
      data: (user) {
        if (user != null) {
          return child;
        } else {
          // Rediriger l'utilisateur vers la page de connexion
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(loginRoute);
          });
          // Afficher un indicateur de chargement pendant la redirection
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
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
