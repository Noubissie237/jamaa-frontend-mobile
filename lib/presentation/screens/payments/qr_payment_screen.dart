import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/dashboard_provider.dart';
import '../../widgets/loading_button.dart';

class QRPaymentScreen extends StatefulWidget {
  const QRPaymentScreen({super.key});

  @override
  State<QRPaymentScreen> createState() => _QRPaymentScreenState();
}

class _QRPaymentScreenState extends State<QRPaymentScreen> {
  bool _isScanning = false;
  bool _qrDetected = false;
  Map<String, dynamic>? _qrData;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement QR Code'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showQRHistory,
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: Column(
        children: [
          // Solde disponible
          _buildBalanceCard(),
          
          // Zone de scan ou résultat
          Expanded(
            child: _qrDetected && _qrData != null
                ? _buildPaymentConfirmation()
                : _buildQRScanner(),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solde disponible',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dashboardProvider.formattedTotalBalance,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ],
          ),
        );
      },
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.2, end: 0);
  }

  Widget _buildQRScanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Zone de scan simulée
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  // Simulation de la caméra
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Cadre de visée
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              // Coins du cadre
                              ...List.generate(4, (index) {
                                return Positioned(
                                  top: index < 2 ? 0 : null,
                                  bottom: index >= 2 ? 0 : null,
                                  left: index % 2 == 0 ? 0 : null,
                                  right: index % 2 == 1 ? 0 : null,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: index < 2 ? BorderSide(color: Theme.of(context).primaryColor, width: 3) : BorderSide.none,
                                        bottom: index >= 2 ? BorderSide(color: Theme.of(context).primaryColor, width: 3) : BorderSide.none,
                                        left: index % 2 == 0 ? BorderSide(color: Theme.of(context).primaryColor, width: 3) : BorderSide.none,
                                        right: index % 2 == 1 ? BorderSide(color: Theme.of(context).primaryColor, width: 3) : BorderSide.none,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              
                              // Ligne de scan animée
                              if (_isScanning)
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 2,
                                    color: Theme.of(context).primaryColor,
                                  )
                                      .animate(onPlay: (controller) => controller.repeat())
                                      .slideY(
                                        begin: 0,
                                        end: 1,
                                        duration: 2000.ms,
                                        curve: Curves.easeInOut,
                                      ),
                                ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        Text(
                          _isScanning
                              ? 'Recherche d\'un QR Code...'
                              : 'Positionnez le QR Code dans le cadre',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  // Overlay d'instructions
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Scannez le QR Code du commerçant pour effectuer un paiement',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleFlash,
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Flash'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isScanning ? _stopScanning : _startScanning,
                  icon: Icon(_isScanning ? Icons.stop : Icons.qr_code_scanner),
                  label: Text(_isScanning ? 'Arrêter' : 'Scanner'),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 500.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 16),
          
          // Option de saisie manuelle
          TextButton.icon(
            onPressed: _showManualEntry,
            icon: const Icon(Icons.keyboard),
            label: const Text('Saisir le code manuellement'),
          )
              .animate()
              .fadeIn(delay: 600.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildPaymentConfirmation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informations du commerçant
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Logo/Avatar du commerçant
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      Icons.store,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    _qrData!['merchantName'] ?? 'Commerçant',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    _qrData!['merchantAddress'] ?? 'Adresse non disponible',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 600.ms),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Détails de la transaction
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Détails du paiement',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildDetailRow('Montant', '${_qrData!['amount']} XAF'),
                  _buildDetailRow('Référence', _qrData!['reference'] ?? 'N/A'),
                  _buildDetailRow('Description', _qrData!['description'] ?? 'Paiement'),
                  
                  if (_qrData!['tax'] != null && _qrData!['tax'] > 0)
                    _buildDetailRow('Taxe', '${_qrData!['tax']} XAF'),
                  
                  const Divider(),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total à payer',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_getTotalAmount()} XAF',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 32),
          
          // Boutons d'action
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: LoadingButton(
                  onPressed: _processQRPayment,
                  isLoading: _isProcessing,
                  child: Text('Payer ${_getTotalAmount()} XAF'),
                ),
              ),
              
              const SizedBox(height: 12),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isProcessing ? null : _resetScanner,
                  child: const Text('Scanner un autre QR Code'),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 600.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });
    
    // Simuler la détection d'un QR Code après 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      if (_isScanning && mounted) {
        _simulateQRDetection();
      }
    });
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
  }

  void _simulateQRDetection() {
    // Données simulées d'un QR Code de paiement
    final mockQRData = {
      'merchantName': 'Boutique Centrale',
      'merchantAddress': 'Yaoundé, Cameroun',
      'amount': 25000,
      'reference': 'PAY-${DateTime.now().millisecondsSinceEpoch}',
      'description': 'Achat de produits',
      'tax': 2500,
    };

    setState(() {
      _isScanning = false;
      _qrDetected = true;
      _qrData = mockQRData;
    });
  }

  void _resetScanner() {
    setState(() {
      _qrDetected = false;
      _qrData = null;
      _isScanning = false;
    });
  }

  double _getTotalAmount() {
    if (_qrData == null) return 0;
    final amount = _qrData!['amount'] ?? 0;
    final tax = _qrData!['tax'] ?? 0;
    return (amount + tax).toDouble();
  }

  Future<void> _processQRPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulation du traitement de paiement
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        // Afficher le dialogue de succès
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildSuccessDialog(),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du paiement: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Widget _buildSuccessDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.check_circle,
              size: 50,
              color: Colors.green,
            ),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          
          const SizedBox(height: 24),
          
          Text(
            'Paiement réussi !',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Votre paiement de ${_getTotalAmount().toStringAsFixed(0)} XAF à ${_qrData!['merchantName']} a été effectué avec succès.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fermer le dialog
                    _resetScanner();
                  },
                  child: const Text('Nouveau paiement'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fermer le dialog
                    Navigator.of(context).pop(); // Retourner à l'écran précédent
                  },
                  child: const Text('Terminé'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleFlash() {
    // TODO: Implémenter le toggle du flash
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contrôle du flash à venir'),
      ),
    );
  }

  void _showManualEntry() {
    // TODO: Implémenter la saisie manuelle
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saisie manuelle à venir'),
      ),
    );
  }

  void _showQRHistory() {
    // TODO: Implémenter l'historique des QR Codes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Historique des paiements QR à venir'),
      ),
    );
  }
}