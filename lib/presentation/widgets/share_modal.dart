import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jamaa_frontend_mobile/core/theme/app_theme.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/qr_code_dialog.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/share_option.dart';

class ShareModal extends StatelessWidget {
  final String cardNumber;
  final String accountName;

  const ShareModal({
    required this.cardNumber,
    required this.accountName,
  });

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: cardNumber));
    
    if (context.mounted) {
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Numéro de carte copié : $cardNumber'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showQRCode(BuildContext context) {
    Navigator.pop(context); // Fermer le modal de partage
    
    showDialog(
      context: context,
      builder: (context) => QRCodeDialog(
        cardNumber: cardNumber,
        accountName: accountName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Titre
          Text(
            'Partager votre numéro de compte',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Numéro de compte
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.credit_card,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        accountName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cardNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Options de partage
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Bouton Copier
                ShareOption(
                  icon: Icons.copy,
                  title: 'Copier le numéro',
                  subtitle: 'Copier dans le presse-papiers',
                  onTap: () => _copyToClipboard(context),
                ),
                
                const SizedBox(height: 16),
                
                // Bouton QR Code
                ShareOption(
                  icon: Icons.qr_code,
                  title: 'Afficher le QR Code',
                  subtitle: 'Générer un code QR à scanner',
                  onTap: () => _showQRCode(context),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Bouton Annuler
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Annuler',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}