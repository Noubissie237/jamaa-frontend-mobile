import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamaa_frontend_mobile/core/theme/app_theme.dart';

class BalanceCard extends StatelessWidget {
  final String balance;
  final bool isVisible;
  final VoidCallback? onToggleVisibility;
  final VoidCallback? onRecharge;
  final String cardNumber;
  final String accountName;

  const BalanceCard({
    super.key,
    required this.balance,
    this.isVisible = true,
    this.onToggleVisibility,
    this.onRecharge,
    required this.cardNumber,
    this.accountName = "JAMAA Money Account",
  });

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor, // Rouge principal
            AppTheme.secondaryColor, // Rouge-rose
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.errorColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec nom du compte et logo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                accountName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.textPrimaryDark.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.textPrimaryDark.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'JAMAA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Numéro de carte
          Text(
            cardNumber,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.2,
            ),
          ),
          
          const Spacer(),
          
          // Bottom section avec solde et bouton recharger
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Solde
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isVisible ? balance : '••••••••',
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: isVisible ? 0.2 : -0.2, end: 0),
                    ),
                    const SizedBox(height: 4),
                    if (onToggleVisibility != null)
                      GestureDetector(
                        onTap: onToggleVisibility,
                        child: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Bouton Recharger
              GestureDetector(
                onTap: onRecharge,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Recharger',
                    style: TextStyle(
                      color: Color(0xFFE53E3E),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}