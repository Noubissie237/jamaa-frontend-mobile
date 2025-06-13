import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('onboarding_seen') ?? false;

    if (!mounted) return;
    if (!hasSeenOnboarding) {
      context.go('/onboarding');
      return;
    }

    // Vérification du token JWT
    final token = prefs.getString('auth_token');
    bool isValid = false;
    if (token != null) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
          final payloadMap = jsonDecode(payload);
          if (payloadMap != null && payloadMap.containsKey('exp')) {
            final exp = payloadMap['exp'];
            final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
            isValid = expiry.isAfter(DateTime.now());
          }
        }
      } catch (_) {}
    }
    if (isValid) {
      // Charger le current user depuis le provider avant de naviguer
      await context.read<AuthProvider>().loadCurrentUserFromPrefs();
      context.go('/main');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo principal
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'JAMAA',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            )
                .animate()
                .scale(duration: 800.ms, curve: Curves.elasticOut)
                .then(delay: 200.ms)
                .shimmer(duration: 1000.ms),

            const SizedBox(height: 32),

            // Nom de l'application
            Text(
              'JAMAA Wallet',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 800.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 16),

            // Slogan
            Text(
              'Votre portefeuille multi-banque',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            )
                .animate()
                .fadeIn(delay: 800.ms, duration: 800.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 64),

            // Indicateur de chargement
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.8),
                ),
                strokeWidth: 3,
              ),
            )
                .animate()
                .fadeIn(delay: 1200.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }
}