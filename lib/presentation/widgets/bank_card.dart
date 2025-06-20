import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/bank_account.dart';
import '../../utils/utils.dart';

class BankCard extends StatelessWidget {
  final BankAccount bankAccount;
  final VoidCallback? onTap;
  final bool isVisible;
  final VoidCallback? onToggleVisibility;
  final VoidCallback? onRecharge;

  const BankCard({
    super.key,
    required this.bankAccount,
    this.onTap,
    this.isVisible = true,
    this.onToggleVisibility,
    this.onRecharge,
  });

  Color _getBankColor() {
    return const Color(0xFF424242);
  }

  @override
  Widget build(BuildContext context) {
    final bankColor = _getBankColor();
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16), // Réduit de 20 à 16
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              bankColor,
              bankColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: bankColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec nom de la banque et logo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    bankAccount.bankName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14, // Réduit de 16 à 14
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 40, // Réduit de 50 à 40
                  height: 40, // Réduit de 50 à 40
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      bankAccount.bankName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14, // Réduit de 16 à 14
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8), // Réduit de 12 à 8
            
            // Numéro de compte masqué
            Text(
              isVisible ? formatAccountNumber(bankAccount.accountNumber) : maskAccountNumber(bankAccount.accountNumber),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14, // Réduit de 16 à 14
                fontWeight: FontWeight.w400,
                letterSpacing: 1.0, // Réduit de 1.2 à 1.0
              ),
            ),
            
            const Spacer(),
            
            // Bottom section avec solde et bouton recharger
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Solde avec toggle visibility
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          isVisible 
                              ? '${bankAccount.balance.toStringAsFixed(2)} ${bankAccount.currency}'
                              : '••••••••',
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20, // Réduit de 24 à 20
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: isVisible ? 0.2 : -0.2, end: 0),
                      ),
                      const SizedBox(height: 2), // Réduit de 4 à 2
                      if (onToggleVisibility != null)
                        GestureDetector(
                          onTap: onToggleVisibility,
                          child: Icon(
                            isVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 18, // Réduit de 20 à 18
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12), // Réduit de 16 à 12
                
                // Bouton Recharger
                if (onRecharge != null)
                  GestureDetector(
                    onTap: onRecharge,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, // Réduit de 20 à 16
                        vertical: 8, // Réduit de 10 à 8
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16), // Réduit de 20 à 16
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Recharger',
                        style: TextStyle(
                          color: bankColor,
                          fontSize: 12, // Réduit de 14 à 12
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}