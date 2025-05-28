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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header du profil
                _buildProfileHeader(user, theme),

                const SizedBox(height: 32),

                // Sections du profil
                _buildProfileSections(context, theme),
              ],
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
                            theme.primaryColor.withOpacity(0.7),
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
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 4),

            Text(
                  user.email,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
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
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          user.isVerified
                              ? Colors.green.withOpacity(0.3)
                              : Colors.orange.withOpacity(0.3),
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
              _buildMenuItem(
                context,
                'Vérification du compte',
                'Documents d\'identité',
                Icons.verified_user_outlined,
                () => _showVerificationDialog(context),
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
              ),
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return _buildSwitchMenuItem(
                    context,
                    'Notifications',
                    'Alertes et rappels',
                    Icons.notifications_outlined,
                    settingsProvider.notificationsEnabled,
                    (value) => settingsProvider.toggleNotifications(),
                  );
                },
              ),
            ])
            .animate()
            .fadeIn(delay: 700.ms, duration: 600.ms)
            .slideX(begin: -0.3, end: 0),

        const SizedBox(height: 16),

        // Section Support
        _buildSection(context, 'Support & Légal', [
              _buildMenuItem(
                context,
                'Centre d\'aide',
                'FAQ et support',
                Icons.help_outline,
                () => _showComingSoon(context),
              ),
              _buildMenuItem(
                context,
                'Nous contacter',
                'Email, téléphone',
                Icons.contact_support_outlined,
                () => _showContactDialog(context),
              ),
              _buildMenuItem(
                context,
                'Conditions d\'utilisation',
                'Termes et conditions',
                Icons.description_outlined,
                () => _showComingSoon(context),
              ),
              _buildMenuItem(
                context,
                'Politique de confidentialité',
                'Protection des données',
                Icons.privacy_tip_outlined,
                () => _showComingSoon(context),
              ),
            ])
            .animate()
            .fadeIn(delay: 800.ms, duration: 600.ms)
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
            color: theme.colorScheme.onSurface.withOpacity(0.5),
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

  void _showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Vérification du compte'),
            content: const Text(
              'Pour vérifier votre compte, vous devez fournir une pièce d\'identité valide. '
              'Cette fonctionnalité sera bientôt disponible.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Compris'),
              ),
            ],
          ),
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
                ),
                RadioListTile<String>(
                  title: const Text('English'),
                  value: 'en',
                  groupValue: settingsProvider.language,
                  onChanged: (value) {
                    if (value != null) {
                      settingsProvider.setLanguage(value);
                      Navigator.pop(context);
                    }
                  },
                ),
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

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nous contacter'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: const Text('support@jamaa.cm'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    // TODO: Ouvrir l'app email
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Téléphone'),
                  subtitle: const Text('+237 123 456 789'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    // TODO: Ouvrir l'app téléphone
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Adresse'),
                  subtitle: const Text('Yaoundé, Cameroun'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
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

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cette fonctionnalité sera bientôt disponible'),
      ),
    );
  }
}
