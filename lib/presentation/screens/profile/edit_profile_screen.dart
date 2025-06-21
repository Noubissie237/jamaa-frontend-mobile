import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cniController = TextEditingController();
  
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _addListeners();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cniController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _cniController.text = user.cniNumber ?? '';
    }
  }

  void _addListeners() {
    _firstNameController.addListener(_onFieldChanged);
    _lastNameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _cniController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      final hasChanges = _firstNameController.text != user.firstName ||
          _lastNameController.text != user.lastName ||
          _emailController.text != user.email ||
          _phoneController.text != user.phone ||
          _cniController.text != (user.cniNumber ?? '');
      
      if (hasChanges != _hasChanges) {
        setState(() {
          _hasChanges = hasChanges;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        centerTitle: true,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveChanges,
              child: const Text('Sauvegarder'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Photo de profil
              _buildProfilePicture(),
              
              const SizedBox(height: 32),
              
              // Informations personnelles
              _buildPersonalInfoSection(),
              
              const SizedBox(height: 24),
              
              // Informations de contact
              _buildContactInfoSection(),
              
              const SizedBox(height: 24),
              
              // Document d'identité
              _buildIdentitySection(),
              
              const SizedBox(height: 32),
              
              // Boutons d'action
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        return Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Center(
                    child: user?.profilePicture != null
                        ? ClipOval(
                            child: Image.network(
                              user!.profilePicture!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            user?.firstName.substring(0, 1).toUpperCase() ?? 'U',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: IconButton(
                      onPressed: _changeProfilePicture,
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut),
            
            const SizedBox(height: 16),
            
            TextButton.icon(
              onPressed: _changeProfilePicture,
              icon: const Icon(Icons.edit),
              label: const Text('Changer la photo'),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms),
          ],
        );
      },
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations personnelles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _firstNameController,
                    label: 'Prénom',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requis';
                      }
                      return null;
                    },
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 600.ms)
                      .slideX(begin: -0.3, end: 0),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _lastNameController,
                    label: 'Nom',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requis';
                      }
                      return null;
                    },
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 600.ms)
                      .slideX(begin: 0.3, end: 0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de contact',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms, duration: 600.ms),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir votre email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Email invalide';
                }
                return null;
              },
            )
                .animate()
                .fadeIn(delay: 800.ms, duration: 600.ms)
                .slideX(begin: -0.2, end: 0),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _phoneController,
              label: 'Téléphone',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir votre numéro';
                }
                if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value.replaceAll(' ', ''))) {
                  return 'Numéro invalide';
                }
                return null;
              },
            )
                .animate()
                .fadeIn(delay: 900.ms, duration: 600.ms)
                .slideX(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document d\'identité',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fadeIn(delay: 1000.ms, duration: 600.ms),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _cniController,
              label: 'Numéro CNI',
              prefixIcon: Icons.badge_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir votre numéro CNI';
                }
                if (value.length < 8) {
                  return 'Numéro CNI invalide';
                }
                return null;
              },
            )
                .animate()
                .fadeIn(delay: 1100.ms, duration: 600.ms)
                .slideX(begin: -0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: LoadingButton(
            onPressed: _hasChanges ? _saveChanges : null,
            isLoading: _isLoading,
            child: const Text('Sauvegarder les modifications'),
          ),
        )
            .animate()
            .fadeIn(delay: 1300.ms, duration: 600.ms)
            .slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _hasChanges ? _resetChanges : null,
            child: const Text('Annuler les modifications'),
          ),
        )
            .animate()
            .fadeIn(delay: 1400.ms, duration: 600.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  void _changeProfilePicture() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Changer la photo de profil',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implémenter la prise de photo
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Prise de photo à venir')),
                );
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implémenter la sélection depuis la galerie
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sélection galerie à venir')),
                );
              },
            ),
            
            if (context.read<AuthProvider>().currentUser?.profilePicture != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Supprimer la photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implémenter la suppression de photo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Suppression de photo à venir')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulation de sauvegarde
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Implémenter la sauvegarde réelle via AuthProvider
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          _hasChanges = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetChanges() {
    _loadUserData();
    setState(() {
      _hasChanges = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Modifications annulées')),
    );
  }
}