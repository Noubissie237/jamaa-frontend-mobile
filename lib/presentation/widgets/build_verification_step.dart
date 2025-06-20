
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamaa_frontend_mobile/core/providers/auth_provider.dart';
import 'package:jamaa_frontend_mobile/core/providers/bank_provider.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/build_summary_row.dart';
import 'package:provider/provider.dart';

Widget buildVerificationStep(BankProvider bankProvider, String? selectedBankId) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final String fullName = '${user?.firstName.toUpperCase() ?? ''} ${user?.lastName.toUpperCase() ?? ''}';
        final selectedBank = bankProvider.getBankById(selectedBankId ?? '');
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirmation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms),
            
            const SizedBox(height: 16),
            
            Text(
              'Vérifiez les informations avant de lier votre compte',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms),
            
            const SizedBox(height: 24),
            
            // Récapitulatif
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    buildSummaryRow(context, 'Banque', selectedBank?.name ?? 'Non sélectionnée'),
                    if (selectedBank?.slogan.isNotEmpty == true)
                      buildSummaryRow(context, 'Slogan', selectedBank!.slogan),
                    buildSummaryRow(context, 'Type de compte', 'Compte Courant'),
                    buildSummaryRow(context, 'Titulaire', fullName),
                    if (selectedBank?.minimumBalance != null)
                      buildSummaryRow(context,
                        'Solde minimum', 
                        '${selectedBank!.minimumBalance.toStringAsFixed(0)} FCFA'
                      ),
                    if (selectedBank?.withdrawFees != null)
                      buildSummaryRow(context,
                        'Frais de retrait', 
                        '${selectedBank!.withdrawFees.toStringAsFixed(0)} FCFA'
                      ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }