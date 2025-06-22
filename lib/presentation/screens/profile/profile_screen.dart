import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/settings_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.go('/main/profile/edit'),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(child: Text('Utilisateur non connecté'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await authProvider.refreshUserData();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(), // Important pour permettre le pull même si le contenu ne dépasse pas l'écran
              child: Column(
                children: [
                  // Header du profil
                  _buildProfileHeader(user, theme),

                  const SizedBox(height: 32),

                  // Sections du profil
                  _buildProfileSections(context, theme),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(user, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Photo de profil
            Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: Center(
                        child:
                            user.profilePicture != null
                                ? ClipOval(
                                  child: Image.network(
                                    user.profilePicture!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : Text(
                                  user.firstName.substring(0, 1).toUpperCase(),
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                      ),
                    )
                  ],
                )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .then(delay: 200.ms)
                .shimmer(duration: 1000.ms),

            const SizedBox(height: 16),

            // Nom et email
            Text(
                  user.fullName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 4),

            Text(
                  user.email,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 8),

            // Badge de vérification
            Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        user.isVerified
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          user.isVerified
                              ? Colors.green.withValues(alpha: 0.3)
                              : Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        user.isVerified ? Icons.verified : Icons.warning,
                        size: 16,
                        color: user.isVerified ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.isVerified ? 'Vérifié' : 'Non vérifié',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: user.isVerified ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 500.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSections(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // Section Compte
        _buildSection(context, 'Compte', [
              _buildMenuItem(
                context,
                'Informations personnelles',
                'Nom, email, téléphone',
                Icons.person_outline,
                () => context.go('/main/profile/edit'),
              ),
              _buildMenuItem(
                context,
                'Sécurité',
                'Code PIN, authentification',
                Icons.security_outlined,
                () => context.go('/main/profile/security'),
              ),
            ])
            .animate()
            .fadeIn(delay: 600.ms, duration: 600.ms)
            .slideX(begin: -0.3, end: 0),

        const SizedBox(height: 16),

        // Section Préférences
        _buildSection(context, 'Préférences', [
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return _buildSwitchMenuItem(
                    context,
                    'Mode sombre',
                    'Interface sombre ou claire',
                    Icons.dark_mode_outlined,
                    settingsProvider.isDarkMode,
                    (value) => settingsProvider.toggleDarkMode(),
                  );
                },
              ),
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return _buildMenuItem(
                    context,
                    'Langue',
                    settingsProvider.language == 'fr' ? 'Français' : 'English',
                    Icons.language_outlined,
                    () => _showLanguageDialog(context, settingsProvider),
                  );
                },
              )
            ])
            .animate()
            .fadeIn(delay: 700.ms, duration: 600.ms)
            .slideX(begin: -0.3, end: 0),

        const SizedBox(height: 32),

        // Bouton de déconnexion
        SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Se déconnecter',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            )
            .animate()
            .fadeIn(delay: 900.ms, duration: 600.ms)
            .slideY(begin: 0.3, end: 0),

        const SizedBox(height: 16),

        // Version de l'app
        Text(
          'Version 1.0.0',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSwitchMenuItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choisir la langue'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('Français'),
                  value: 'fr',
                  groupValue: settingsProvider.language,
                  onChanged: (value) {
                    if (value != null) {
                      settingsProvider.setLanguage(value);
                      Navigator.pop(context);
                    }
                  },
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Se déconnecter'),
            content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AuthProvider>().logout();
                  context.go('/login');
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Se déconnecter'),
              ),
            ],
          ),
    );
  }
}
