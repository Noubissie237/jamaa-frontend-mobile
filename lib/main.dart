import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jamaa_frontend_mobile/core/providers/card_provider.dart';
import 'package:jamaa_frontend_mobile/core/providers/transfert_provider.dart'; 
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/dashboard_provider.dart';
import 'core/providers/bank_provider.dart';
import 'core/providers/transaction_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const JamaaApp());
}

class JamaaApp extends StatelessWidget {
  const JamaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => BankProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => TransfertProvider()),
        ChangeNotifierProvider(create: (_) => CardProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp.router(
            title: 'JAMAA Wallet',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.isDarkMode 
                ? ThemeMode.dark 
                : ThemeMode.light,
            routerConfig: AppRouter.router,
            
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            
            // Mise à jour des locales supportées
            supportedLocales: const [
              Locale('fr', 'FR'), 
              Locale('en', 'US'),  
            ],
            
            // Locale dynamique basée sur les paramètres utilisateur
            locale: Locale(settingsProvider.language, 
                          settingsProvider.language == 'fr' ? 'FR' : 'US'),
          );
        },
      ),
    );
  }
}