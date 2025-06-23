import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isEmailSent = false; // État pour basculer entre les étapes
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _generatedCode; // Code généré côté frontend
  DateTime? _codeExpiration; // Expiration du code

  static const String _smtpHost = 'smtp.gmail.com';
  static const int _smtpPort = 587;
  static const String _senderEmail = 'supp0rt.jamaa@gmail.com';
  static const String _senderPassword = 'szdhtjxnjdsoxmph';

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Génère un code à 6 chiffres
  String _generateVerificationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Vérifie si l'email existe dans les utilisateurs enregistrés
  Future<bool> _checkIfEmailExists(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString('user_email');
      final authProvider = context.read<AuthProvider>();
      // Vérifier si l'email correspond à l'utilisateur stocké localement
      if (storedEmail != null && storedEmail.toLowerCase() == email.toLowerCase()) {
        return true;
      }
      
      if(await authProvider.emailExist(email)) {
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ [EMAIL_CHECK] Erreur: $e');
      return false;
    }
  }

  /// Envoie un email avec le code de vérification
  Future<bool> _sendVerificationEmail(String email, String code) async {
    try {
      debugPrint('📧 [EMAIL] Envoi du code $code à $email');
      
      // Configuration du serveur SMTP
      final smtpServer = SmtpServer(
        _smtpHost,
        port: _smtpPort,
        username: _senderEmail,
        password: _senderPassword,
        allowInsecure: true,
      );

      // Création du message
      final message = Message()
        ..from = Address(_senderEmail, 'JAMAA')
        ..recipients.add(email)
        ..subject = 'Code de récupération JAMAA'
        ..html = '''
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
            <div style="text-align: center; margin-bottom: 30px;">
              <h1 style="color: #2196F3; margin: 0;">JAMAA</h1>
              <p style="color: #666; margin: 5px 0;">Récupération de mot de passe</p>
            </div>
            
            <div style="background: #f5f5f5; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
              <h2 style="color: #333; margin-top: 0;">Code de vérification</h2>
              <p style="color: #666; line-height: 1.5;">
                Voici votre code de vérification pour réinitialiser votre mot de passe :
              </p>
              <div style="text-align: center; margin: 20px 0;">
                <span style="font-size: 32px; font-weight: bold; color: #2196F3; letter-spacing: 5px; background: white; padding: 15px 25px; border-radius: 5px; display: inline-block;">
                  $code
                </span>
              </div>
              <p style="color: #666; font-size: 14px;">
                Ce code expire dans 15 minutes pour des raisons de sécurité.
              </p>
            </div>
            
            <div style="border-top: 1px solid #eee; padding-top: 20px; text-align: center;">
              <p style="color: #999; font-size: 12px; margin: 0;">
                Si vous n'avez pas demandé cette réinitialisation, ignorez ce message.
              </p>
            </div>
          </div>
        ''';

      // Envoi du message
      final sendReport = await send(message, smtpServer);
      debugPrint('✅ [EMAIL] Message envoyé: ${sendReport.toString()}');
      return true;
      
    } catch (e) {
      debugPrint('❌ [EMAIL] Erreur lors de l\'envoi: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
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
                const SizedBox(height: 20),

                // Icône et titre
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Icon(
                          _isEmailSent ? Icons.lock_reset : Icons.email_outlined,
                          size: 40,
                          color: theme.primaryColor,
                        ),
                      ).animate().scale(
                        duration: 300.ms,
                        curve: Curves.elasticOut,
                      ),

                      const SizedBox(height: 24),

                      Text(
                        _isEmailSent 
                          ? 'Code de vérification envoyé'
                          : 'Récupérer votre mot de passe',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                       .fadeIn(delay: 100.ms, duration: 300.ms)
                       .slideY(begin: 0.3, end: 0),

                      const SizedBox(height: 8),

                      Text(
                        _isEmailSent
                          ? 'Nous avons envoyé un code de vérification à ${_emailController.text}'
                          : 'Saisissez votre adresse email pour recevoir un code de récupération',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                       .fadeIn(delay: 150.ms, duration: 300.ms)
                       .slideY(begin: 0.3, end: 0),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Étape 1: Saisie de l'email
                if (!_isEmailSent) ...[
                  CustomTextField(
                    controller: _emailController,
                    label: 'Adresse email',
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
                  ).animate()
                   .fadeIn(delay: 200.ms, duration: 250.ms)
                   .slideX(begin: -0.2, end: 0),

                  const SizedBox(height: 32),

                  LoadingButton(
                    onPressed: _sendResetCode,
                    isLoading: _isLoading,
                    child: const Text('Envoyer le code'),
                  ).animate()
                   .fadeIn(delay: 250.ms, duration: 250.ms)
                   .slideY(begin: 0.3, end: 0),
                ],

                // Étape 2: Saisie du code et nouveau mot de passe
                if (_isEmailSent) ...[
                  CustomTextField(
                    controller: _codeController,
                    label: 'Code de vérification',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.verified_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez saisir le code de vérification';
                      }
                      if (value.length != 6) {
                        return 'Le code doit contenir 6 chiffres';
                      }
                      return null;
                    },
                  ).animate()
                   .fadeIn(delay: 200.ms, duration: 250.ms)
                   .slideX(begin: -0.2, end: 0),

                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _newPasswordController,
                    label: 'Nouveau mot de passe',
                    obscureText: _obscureNewPassword,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez saisir un nouveau mot de passe';
                      }
                      if (value.length < 8) {
                        return 'Le mot de passe doit contenir au moins 8 caractères';
                      }
                      if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
                        return 'Le mot de passe doit contenir au moins une lettre et un chiffre';
                      }
                      return null;
                    },
                  ).animate()
                   .fadeIn(delay: 250.ms, duration: 250.ms)
                   .slideX(begin: -0.2, end: 0),

                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmer le mot de passe',
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ).animate()
                   .fadeIn(delay: 300.ms, duration: 250.ms)
                   .slideX(begin: -0.2, end: 0),

                  const SizedBox(height: 32),

                  LoadingButton(
                    onPressed: _resetPassword,
                    isLoading: _isLoading,
                    child: const Text('Réinitialiser le mot de passe'),
                  ).animate()
                   .fadeIn(delay: 350.ms, duration: 250.ms)
                   .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 16),

                  // Option pour renvoyer le code
                  Center(
                    child: TextButton(
                      onPressed: _isLoading ? null : _resendCode,
                      child: Text(
                        'Renvoyer le code',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ).animate()
                   .fadeIn(delay: 400.ms, duration: 250.ms),
                ],

                const SizedBox(height: 24),

                // Messages d'erreur et de succès
                if (_errorMessage != null)
                  Container(
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
                            _errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                   .fadeIn(duration: 200.ms)
                   .shake(duration: 300.ms),

                if (_successMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                   .fadeIn(duration: 200.ms)
                   .slideY(begin: -0.3, end: 0),

                const SizedBox(height: 32),

                // Retour à la connexion
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = false;
                      });
                      context.go('/login');
                    },
                    child: Text(
                      'Retour à la connexion',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 250.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      
      // 1. Vérifier si l'email existe
      debugPrint('🔍 [RESET] Vérification de l\'email: $email');
      final emailExists = await _checkIfEmailExists(email);
      
      if (!emailExists) {
        setState(() {
          _errorMessage = 'Aucun compte associé à cette adresse email';
        });
        return;
      }
      
      // 2. Générer le code de vérification
      _generatedCode = _generateVerificationCode();
      _codeExpiration = DateTime.now().add(const Duration(minutes: 15));
      
      debugPrint('🔑 [RESET] Code généré: $_generatedCode');
      debugPrint('⏰ [RESET] Expiration: $_codeExpiration');
      
      // 3. Envoyer l'email
      final emailSent = await _sendVerificationEmail(email, _generatedCode!);
      
      if (emailSent) {
        setState(() {
          _isEmailSent = true;
          _successMessage = 'Code envoyé avec succès à $email';
        });
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de l\'envoi de l\'email. Vérifiez votre configuration SMTP.';
        });
      }
      
    } catch (e) {
      debugPrint('❌ [RESET] Exception: $e');
      setState(() {
        _errorMessage = 'Erreur de connexion. Veuillez réessayer.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final enteredCode = _codeController.text.trim();
      
      // 1. Vérifier le code et l'expiration
      if (_generatedCode == null || _codeExpiration == null) {
        setState(() {
          _errorMessage = 'Code non généré. Veuillez recommencer.';
        });
        return;
      }
      
      if (DateTime.now().isAfter(_codeExpiration!)) {
        setState(() {
          _errorMessage = 'Le code a expiré. Veuillez en demander un nouveau.';
        });
        return;
      }
      
      if (enteredCode != _generatedCode) {
        setState(() {
          _errorMessage = 'Code incorrect. Veuillez réessayer.';
        });
        return;
      }
      
      // 2. Le code est valide, mettre à jour le mot de passe via AuthProvider
      debugPrint('✅ [RESET] Code valide, mise à jour du mot de passe...');
      
      final authProvider = context.read<AuthProvider>();
      authProvider.getUserByEmail(_emailController.text.trim());
      final userId = authProvider.tmpUserId;
      debugPrint('🔑 [RESET] ID utilisateur: $userId');
      // Mettre à jour le mot de passe
      await authProvider.updatePassword(userId!,_newPasswordController.text);
      
      setState(() {
        _successMessage = 'Mot de passe réinitialisé avec succès !';
      });
      
      debugPrint('✅ [RESET] Mot de passe mis à jour avec succès');
      
      // Rediriger vers la page principale après 2 secondes
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          context.go('/login');
        }
      });
      
    } catch (e) {
      debugPrint('❌ [RESET] Erreur lors de la mise à jour: $e');
      setState(() {
        _errorMessage = 'Erreur lors de la réinitialisation. Veuillez réessayer.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Générer un nouveau code
      _generatedCode = _generateVerificationCode();
      _codeExpiration = DateTime.now().add(const Duration(minutes: 15));
      
      debugPrint('🔄 [RESEND] Nouveau code: $_generatedCode');
      
      // Renvoyer l'email
      final emailSent = await _sendVerificationEmail(_emailController.text.trim(), _generatedCode!);
      
      if (emailSent) {
        setState(() {
          _successMessage = 'Code renvoyé avec succès !';
        });
      } else {
        setState(() {
          _errorMessage = 'Erreur lors du renvoi de l\'email.';
        });
      }
    } catch (e) {
      debugPrint('❌ [RESEND] Erreur: $e');
      setState(() {
        _errorMessage = 'Erreur lors du renvoi du code.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}