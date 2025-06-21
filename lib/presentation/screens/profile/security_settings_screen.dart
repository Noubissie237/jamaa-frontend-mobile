import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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