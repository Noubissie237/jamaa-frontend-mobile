import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/settings_provider.dart';
import '../../widgets/custom_text_field.dart';
// import '../../widgets/loading_button.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  
  bool _isChangingPassword = false;
  bool _isChangingPin = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sécurité'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Section Authentification
            _buildAuthenticationSection(),
            
            const SizedBox(height: 24),
            
            // Section Mot de passe
            _buildPasswordSection(),
            
            const SizedBox(height: 24),
            
            // Section Code PIN
            _buildPinSection(),
            
            const SizedBox(height: 24),
            
            // Section Sécurité avancée
            _buildAdvancedSecuritySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Authentification',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms),
            
            const SizedBox(height: 16),
            
            Consumer<SettingsProvider>(
              builder: (context, settingsProvider, child) {
                return ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: const Text('Authentification biométrique'),
                  subtitle: const Text('Utiliser l\'empreinte ou la reconnaissance faciale'),
                  trailing: Switch(
                    value: settingsProvider.biometricEnabled,
                    onChanged: (value) {
                      if (value) {
                        _showBiometricSetupDialog();
                      } else {
                        settingsProvider.toggleBiometric();
                      }
                    },
                  ),
                  contentPadding: EdgeInsets.zero,
                );
              },
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideX(begin: -0.3, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mot de passe',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isChangingPassword = !_isChangingPassword;
                    });
                  },
                  child: Text(_isChangingPassword ? 'Annuler' : 'Modifier'),
                ),
              ],
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms),
            
            if (!_isChangingPassword) ...[
              const SizedBox(height: 8),
              Text(
                'Dernière modification: Il y a 30 jours',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms),
            ] else ...[
              const SizedBox(height: 16),
              
CustomTextField(
                controller: _currentPasswordController,
                label: 'Mot de passe actuel',
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir votre mot de passe actuel';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 600.ms)
                  .slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _newPasswordController,
                label: 'Nouveau mot de passe',
                obscureText: true,
                prefixIcon: Icons.lock,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un nouveau mot de passe';
                  }
                  if (value.length < 8) {
                    return 'Le mot de passe doit contenir au moins 8 caractères';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms)
                  .slideX(begin: 0.2, end: 0),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Confirmer le mot de passe',
                obscureText: true,
                prefixIcon: Icons.lock,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez confirmer le mot de passe';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 600.ms)
                  .slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _changePassword,
                  child: const Text('Changer le mot de passe'),
                ),
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPinSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Code PIN',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isChangingPin = !_isChangingPin;
                    });
                  },
                  child: Text(_isChangingPin ? 'Annuler' : 'Modifier'),
                ),
              ],
            )
                .animate()
                .fadeIn(delay: 900.ms, duration: 600.ms),
            
            if (!_isChangingPin) ...[
              const SizedBox(height: 8),
              Text(
                'Code PIN configuré',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              )
                  .animate()
                  .fadeIn(delay: 1000.ms, duration: 600.ms),
            ] else ...[
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _currentPinController,
                label: 'Code PIN actuel',
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                prefixIcon: Icons.pin,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir votre code PIN actuel';
                  }
                  if (value.length != 4) {
                    return 'Le code PIN doit contenir 4 chiffres';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 1100.ms, duration: 600.ms)
                  .slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _newPinController,
                label: 'Nouveau code PIN',
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                prefixIcon: Icons.pin,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un nouveau code PIN';
                  }
                  if (value.length != 4) {
                    return 'Le code PIN doit contenir 4 chiffres';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 1200.ms, duration: 600.ms)
                  .slideX(begin: 0.2, end: 0),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _confirmPinController,
                label: 'Confirmer le code PIN',
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                prefixIcon: Icons.pin,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez confirmer le code PIN';
                  }
                  if (value != _newPinController.text) {
                    return 'Les codes PIN ne correspondent pas';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 1300.ms, duration: 600.ms)
                  .slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _changePin,
                  child: const Text('Changer le code PIN'),
                ),
              )
                  .animate()
                  .fadeIn(delay: 1400.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSecuritySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sécurité avancée',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fadeIn(delay: 1500.ms, duration: 600.ms),
            
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Authentification à deux facteurs'),
              subtitle: const Text('Sécurité renforcée avec SMS'),
              trailing: Switch(
                value: false, // TODO: Lier à un provider
                onChanged: (value) {
                  _show2FADialog();
                },
              ),
              contentPadding: EdgeInsets.zero,
            )
                .animate()
                .fadeIn(delay: 1600.ms, duration: 600.ms)
                .slideX(begin: -0.3, end: 0),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.phonelink_lock),
              title: const Text('Sessions actives'),
              subtitle: const Text('Gérer les appareils connectés'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showActiveSessions,
              contentPadding: EdgeInsets.zero,
            )
                .animate()
                .fadeIn(delay: 1700.ms, duration: 600.ms)
                .slideX(begin: 0.3, end: 0),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historique de connexion'),
              subtitle: const Text('Voir les dernières connexions'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showLoginHistory,
              contentPadding: EdgeInsets.zero,
            )
                .animate()
                .fadeIn(delay: 1800.ms, duration: 600.ms)
                .slideX(begin: -0.3, end: 0),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.lock_reset, color: Colors.red),
              title: const Text('Verrouiller le compte', style: TextStyle(color: Colors.red)),
              subtitle: const Text('Suspendre temporairement l\'accès'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
              onTap: _showLockAccountDialog,
              contentPadding: EdgeInsets.zero,
            )
                .animate()
                .fadeIn(delay: 1900.ms, duration: 600.ms)
                .slideX(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }

  void _showBiometricSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentification biométrique'),
        content: const Text(
          'Voulez-vous activer l\'authentification biométrique ? '
          'Vous pourrez utiliser votre empreinte digitale ou la reconnaissance faciale '
          'pour vous connecter rapidement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SettingsProvider>().toggleBiometric();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Authentification biométrique activée'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Activer'),
          ),
        ],
      ),
    );
  }

  void _show2FADialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentification à deux facteurs'),
        content: const Text(
          'L\'authentification à deux facteurs ajoute une couche de sécurité supplémentaire '
          'en demandant un code SMS en plus de votre mot de passe.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité à venir'),
                ),
              );
            },
            child: const Text('Configurer'),
          ),
        ],
      ),
    );
  }

  void _showActiveSessions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sessions actives',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      _buildSessionItem(
                        'Samsung Galaxy S21',
                        'Android • Yaoundé, Cameroun',
                        'Maintenant',
                        true,
                      ),
                      _buildSessionItem(
                        'iPhone 13',
                        'iOS • Douala, Cameroun',
                        'Il y a 2 heures',
                        false,
                      ),
                      _buildSessionItem(
                        'Chrome sur Windows',
                        'Web • Bafoussam, Cameroun',
                        'Il y a 1 jour',
                        false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSessionItem(String device, String info, String lastSeen, bool isCurrent) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          device.contains('Samsung') || device.contains('iPhone') 
              ? Icons.phone_android 
              : Icons.computer,
          color: isCurrent ? Colors.green : Colors.grey,
        ),
        title: Row(
          children: [
            Expanded(child: Text(device)),
            if (isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Actuelle',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(info),
            Text('Dernière activité: $lastSeen'),
          ],
        ),
        trailing: isCurrent ? null : IconButton(
          icon: const Icon(Icons.logout, color: Colors.red),
          onPressed: () {
            // TODO: Déconnecter la session
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Session déconnectée')),
            );
          },
        ),
      ),
    );
  }

  void _showLoginHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Historique de connexion à venir')),
    );
  }

  void _showLockAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verrouiller le compte'),
        content: const Text(
          'Êtes-vous sûr de vouloir verrouiller votre compte ? '
          'Vous ne pourrez plus y accéder jusqu\'à ce que vous le déverrouilliez '
          'via le support client.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité à venir'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Verrouiller'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    // TODO: Implémenter le changement de mot de passe
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mot de passe modifié avec succès'),
        backgroundColor: Colors.green,
      ),
    );
    
    setState(() {
      _isChangingPassword = false;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });
  }

  void _changePin() {
    // TODO: Implémenter le changement de code PIN
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code PIN modifié avec succès'),
        backgroundColor: Colors.green,
      ),
    );
    
    setState(() {
      _isChangingPin = false;
      _currentPinController.clear();
      _newPinController.clear();
      _confirmPinController.clear();
    });
  }
}