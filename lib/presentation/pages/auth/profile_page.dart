import 'package:argentenveloppes/domain/entities/user.dart';
import 'package:argentenveloppes/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: currentUserAsync.when(
        data: (user) => _buildUserProfile(context, user, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erreur: $error',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(currentUserProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, User? user, WidgetRef ref) {
    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Vous n\'êtes pas connecté',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Se connecter'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null
                ? Text(
                    _getInitials(user.displayName ?? user.email ?? 'U'),
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(height: 24),

          // Nom d'utilisateur
          Text(
            user.displayName ?? 'Utilisateur',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Email
          Text(
            user.email ?? 'Aucun email',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // Informations sur le compte
          _buildProfileInfoCard(context, user),
          
          const SizedBox(height: 24),
          
          // Bouton de déconnexion
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'DÉCONNEXION',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => _showLogoutDialog(context, ref),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoCard(BuildContext context, User user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations du compte',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.email, 'Email', user.email ?? 'Non renseigné'),
            const Divider(),
            _buildInfoRow(
              Icons.verified_user,
              'Email vérifié',
              user.emailVerified ? 'Oui' : 'Non',
            ),
            const Divider(),
            _buildInfoRow(
              Icons.person,
              'Type de compte',
              user.isAnonymous ? 'Anonyme' : 'Vérifié',
            ),
            const Divider(),
            _buildInfoRow(Icons.fingerprint, 'ID utilisateur', user.uid),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      await ref.read(authNotifierProvider.notifier).signOut();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  String _getInitials(String fullName) {
    List<String> names = fullName.split(' ');
    String initials = '';
    if (names.length > 0) {
      initials += names[0][0];
      
      if (names.length > 1) {
        initials += names[1][0];
      }
    }
    return initials.toUpperCase();
  }
}
