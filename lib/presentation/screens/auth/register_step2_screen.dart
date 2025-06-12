import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_button.dart';

class RegisterStep2Screen extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const RegisterStep2Screen({
    super.key,
    required this.userData,
  });

  @override
  State<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _cniController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  File? _cniRectoImage;
  File? _cniVersoImage;
  bool _acceptTerms = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();
    });
  }

  @override
  void dispose() {
    _cniController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription - Étape 2/2'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Titre et description
                Text(
                  'Documents d\'identité',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.3, end: 0),

                const SizedBox(height: 8),

                Text(
                  'Finalisez votre inscription avec vos documents',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 600.ms)
                    .slideY(begin: -0.3, end: 0),

                const SizedBox(height: 32),

                // Indicateur de progression
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms),

                const SizedBox(height: 32),

                // Numéro CNI
                CustomTextField(
                  controller: _cniController,
                  label: 'N° CNI',
                  prefixIcon: Icons.badge_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir votre numéro de CNI';
                    }
                    if (value.length < 8) {
                      return 'Numéro de CNI invalide';
                    }
                    return null;
                  },
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideX(begin: -0.2, end: 0),

                const SizedBox(height: 24),

                // CNI Recto
                _buildImageSelector(
                  title: 'Photo recto de la CNI',
                  subtitle: 'Prenez une photo claire du recto de votre CNI',
                  image: _cniRectoImage,
                  onTap: () => _pickImage(isRecto: true),
                  delay: 500,
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 600.ms)
                    .slideX(begin: 0.2, end: 0),

                const SizedBox(height: 16),

                // CNI Verso
                _buildImageSelector(
                  title: 'Photo verso de la CNI',
                  subtitle: 'Prenez une photo claire du verso de votre CNI',
                  image: _cniVersoImage,
                  onTap: () => _pickImage(isRecto: false),
                  delay: 600,
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 600.ms)
                    .slideX(begin: -0.2, end: 0),

                const SizedBox(height: 24),

                // Acceptation des conditions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodyMedium,
                          children: [
                            const TextSpan(text: 'J\'accepte les '),
                            TextSpan(
                              text: 'conditions d\'utilisation',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' et la '),
                            TextSpan(
                              text: 'politique de confidentialité',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 600.ms),

                const SizedBox(height: 32),

                // Bouton d'inscription
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return LoadingButton(
                      onPressed: _canRegister() ? () => _register(authProvider) : null,
                      isLoading: authProvider.isLoading,
                      child: const Text('Finaliser l\'inscription'),
                    );
                  },
                )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 24),

                // Affichage des erreurs
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.error != null) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authProvider.error!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .shake(duration: 500.ms);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSelector({
    required String title,
    required String subtitle,
    required File? image,
    required VoidCallback onTap,
    required int delay,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: image != null 
                ? theme.primaryColor 
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: image != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: image != null 
              ? theme.primaryColor.withValues(alpha: 0.05)
              : null,
        ),
        child: Column(
          children: [
            if (image != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  image,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Image ajoutée',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Icon(
                Icons.camera_alt_outlined,
                size: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (image != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.camera_alt, size: 16),
                label: const Text('Changer l\'image'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage({required bool isRecto}) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (image != null) {
                  setState(() {
                    if (isRecto) {
                      _cniRectoImage = File(image.path);
                    } else {
                      _cniVersoImage = File(image.path);
                    }
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (image != null) {
                  setState(() {
                    if (isRecto) {
                      _cniRectoImage = File(image.path);
                    } else {
                      _cniVersoImage = File(image.path);
                    }
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _canRegister() {
    return _acceptTerms && 
           _cniRectoImage != null && 
           _cniVersoImage != null;
  }

  Future<void> _register(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;
    if (!_canRegister()) return;

    authProvider.clearError();
    
    await authProvider.register(
      firstName: widget.userData['firstName'],
      lastName: widget.userData['lastName'],
      email: widget.userData['email'],
      phone: widget.userData['phone'],
      password: widget.userData['password'],
      cniNumber: _cniController.text.trim(),
      cniRectoImage: _cniRectoImage?.path,
      cniVersoImage: _cniVersoImage?.path, 
    );

    if (mounted && authProvider.isAuthenticated) {
      context.go('/pin-setup');
    }
  }
}