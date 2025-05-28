import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/dashboard_provider.dart';
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
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
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
            locale: Locale(settingsProvider.language),
            supportedLocales: const [
              Locale('fr', ''),
              Locale('en', ''),
            ],
          );
        },
      ),
    );
  }
}