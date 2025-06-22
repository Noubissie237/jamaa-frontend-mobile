import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamaa_frontend_mobile/core/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/custom_text_field.dart';

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
            
            // Section Mot de passe
            _buildPasswordSection(),
            
            const SizedBox(height: 24),
            
            // Section Code PIN
            _buildPinSection(),
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
                'Mot de passe configuré',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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

Future<void> _changePassword() async {
  final prefs = await SharedPreferences.getInstance();
  final oldPassword = prefs.getString('user_password');

  if (_currentPasswordController.text.trim() != oldPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Mot de passe actuel incorrect'),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    return;
  }

  if (_newPasswordController.text.trim() != _confirmPasswordController.text.trim()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Les mots de passe ne correspondent pas'),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    return;
  }

  // Validation supplémentaire du nouveau mot de passe
  if (_newPasswordController.text.trim().length < 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Au moins 6 caractères sont requis'),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    return;
  }

  // Dialog de confirmation avec avertissement de déconnexion
  final bool? confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Confirmer le changement',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Êtes-vous sûr de vouloir changer votre mot de passe ?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Important :',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Vous serez automatiquement déconnecté\n'
                    '• Vous devrez vous reconnecter avec votre nouveau mot de passe\n'
                    '• Assurez-vous de bien mémoriser le nouveau mot de passe',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(
              'Annuler',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Confirmer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );

  // Si l'utilisateur a confirmé
  if (confirmed == true) {
    try {
      setState(() {
        _isChangingPassword = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updatePassword(_confirmPasswordController.text.trim());

      if (mounted) {
        // Message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mot de passe modifié avec succès !.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );

        // Nettoyer les champs
        setState(() {
          _isChangingPassword = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });

      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isChangingPassword = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Erreur lors du changement : ${error.toString()}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}

  Future<void> _changePin() async {
    
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('user_pin');
    
    if(pin != _currentPinController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
          content: Text('Code PIN incorrect'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if(_newPinController.text.trim() != _confirmPinController.text.trim()){
              ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
          content: Text('Les codes PIN ne correspondent pas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    prefs.setString('user_pin', _confirmPinController.text.trim());

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