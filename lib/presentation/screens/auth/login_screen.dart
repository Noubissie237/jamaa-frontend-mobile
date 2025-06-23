import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _canUsePinLogin = false; // Flag pour savoir si le login PIN est disponible

  @override
  void initState() {
    super.initState();
    // Réinitialise l'erreur à chaque fois qu'on arrive sur la page de login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();
      
      // Vérifier si les credentials sont disponibles pour le login PIN
      _checkPinLoginAvailability();
    });
  }

  /// Vérifie si les credentials sont stockés dans SharedPreferences
  /// pour déterminer si le login via PIN est disponible
  Future<void> _checkPinLoginAvailability() async {
    try {
      // Petit délai pour s'assurer que les opérations de SharedPreferences sont terminées
      await Future.delayed(const Duration(milliseconds: 100));
      
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');
      final userPassword = prefs.getString('user_password');
      
      debugPrint('🔍 [PIN_CHECK] Vérification des credentials stockés...');
      debugPrint('   📧 Email: ${userEmail != null ? 'Présent' : 'Absent'}');
      debugPrint('   🔒 Password: ${userPassword != null ? 'Présent' : 'Absent'}');
      
      final canUsePin = userEmail != null && 
                      userPassword != null && 
                      userEmail.isNotEmpty && 
                      userPassword.isNotEmpty;
      
      debugPrint('   ✅ Login PIN disponible: $canUsePin');
      
      if (mounted) {
        setState(() {
          _canUsePinLogin = canUsePin;
        });
      }
    } catch (e) {
      debugPrint('❌ [PIN_CHECK] Erreur lors de la vérification: $e');
      if (mounted) {
        setState(() {
          _canUsePinLogin = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo et titre
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'J',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ).animate().scale(
                        duration: 300.ms,
                        curve: Curves.elasticOut,
                      ),

                      const SizedBox(height: 24),

                      Text(
                            'Bon retour !',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 300.ms)
                          .slideY(begin: 0.3, end: 0),

                      const SizedBox(height: 8),

                      Text(
                            'Connectez-vous à votre compte JAMAA',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 
                                0.7,
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 150.ms, duration: 300.ms)
                          .slideY(begin: 0.3, end: 0),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Champs de saisie
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
                          return 'Veuillez saisir un email valide';
                        }
                        return null;
                      },
                    )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 250.ms)
                    .slideX(begin: -0.2, end: 0),

                const SizedBox(height: 16),

                CustomTextField(
                      controller: _passwordController,
                      label: 'Mot de passe',
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez saisir votre mot de passe';
                        }
                        if (value.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                    )
                    .animate()
                    .fadeIn(delay: 250.ms, duration: 250.ms)
                    .slideX(begin: -0.2, end: 0),

                const SizedBox(height: 16),

                // Mot de passe oublié
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/main/forgot-password'),
                    child: Text(
                      'Mot de passe oublié ?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 250.ms),

                const SizedBox(height: 32),

                // Bouton de connexion
                Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return LoadingButton(
                          onPressed: () => _login(authProvider),
                          isLoading: authProvider.isLoading,
                          child: const Text('Se connecter'),
                        );
                      },
                    )
                    .animate()
                    .fadeIn(delay: 350.ms, duration: 250.ms)
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
                          .fadeIn(duration: 200.ms)
                          .shake(duration: 300.ms);
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Divider et options de connexion alternatives (seulement si PIN disponible)
                if (_canUsePinLogin) ...[
                  const SizedBox(height: 32),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'ou',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ).animate().fadeIn(delay: 400.ms, duration: 250.ms),

                  const SizedBox(height: 24),

                  // Options de connexion alternatives
                  Column(
                    children: [
                      // Connexion via code PIN
                      OutlinedButton.icon(
                            onPressed: () => context.go('/pin-login'),
                            icon: const Icon(Icons.pin_outlined),
                            label: const Text('Connexion via code PIN'),
                          )
                          .animate()
                          .fadeIn(delay: 450.ms, duration: 250.ms)
                          .slideY(begin: 0.3, end: 0),
                    ],
                  ),
                ],

                const SizedBox(height: 32),

                // Lien vers l'inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pas encore de compte ? ',
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: Text(
                        'S\'inscrire',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 500.ms, duration: 250.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    authProvider.clearError();

    await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted && authProvider.isAuthenticated) {
      context.go('/main');
    }
  }
}