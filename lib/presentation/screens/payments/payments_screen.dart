import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiements'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Actions rapides
            _buildQuickPayments(context),
            
            const SizedBox(height: 32),
            
            // Services de paiement
            _buildPaymentServices(context),
            
            const SizedBox(height: 32),
            
            // Historique des paiements récents
            _buildRecentPayments(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPayments(BuildContext context) {
    final quickPayments = [
      PaymentOption(
        title: 'Scanner QR Code',
        description: 'Payer un commerçant',
        icon: Icons.qr_code_scanner,
        color: Colors.blue,
        onTap: () => context.go('/main/payments/qr'),
      ),
      PaymentOption(
        title: 'Payer une facture',
        description: 'Eau, électricité, TV...',
        icon: Icons.receipt_long,
        color: Colors.green,
        onTap: () => context.go('/main/payments/bills'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
Text(
          'Paiements rapides',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: -0.2, end: 0),
        
        const SizedBox(height: 16),
        
        Row(
          children: quickPayments.map((payment) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: payment == quickPayments.last ? 0 : 8,
                  left: payment == quickPayments.first ? 0 : 8,
                ),
                child: _buildPaymentCard(context, payment),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(BuildContext context, PaymentOption option) {
    return Card(
      child: InkWell(
        onTap: option.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: option.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  option.icon,
                  size: 30,
                  color: option.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                option.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                option.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildPaymentServices(BuildContext context) {
    final services = [
      ServiceCategory(
        title: 'Utilités',
        icon: Icons.home,
        color: Colors.orange,
        services: [
          PaymentService('ENEO', 'Électricité', Icons.electrical_services, Colors.yellow),
          PaymentService('CAMWATER', 'Eau', Icons.water_drop, Colors.blue),
          PaymentService('Canal+', 'Télévision', Icons.tv, Colors.purple),
        ],
      ),
      ServiceCategory(
        title: 'Télécommunications',
        icon: Icons.phone,
        color: Colors.green,
        services: [
          PaymentService('MTN', 'Crédit téléphone', Icons.phone_android, Colors.yellow),
          PaymentService('Orange', 'Crédit téléphone', Icons.phone_android, Colors.orange),
          PaymentService('Camtel', 'Internet', Icons.wifi, Colors.blue),
        ],
      ),
      ServiceCategory(
        title: 'Transport',
        icon: Icons.directions_bus,
        color: Colors.blue,
        services: [
          PaymentService('Uber', 'Transport', Icons.local_taxi, Colors.black),
          PaymentService('Bolt', 'Transport', Icons.local_taxi, Colors.green),
          PaymentService('Yango', 'Transport', Icons.local_taxi, Colors.red),
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services de paiement',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 600.ms)
            .slideY(begin: -0.2, end: 0),
        
        const SizedBox(height: 16),
        
        ...services.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          return _buildServiceCategory(context, category)
              .animate()
              .fadeIn(delay: (400 + index * 100).ms, duration: 600.ms)
              .slideX(begin: 0.3, end: 0);
        }).toList(),
      ],
    );
  }

  Widget _buildServiceCategory(BuildContext context, ServiceCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: category.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            category.icon,
            color: category.color,
            size: 20,
          ),
        ),
        title: Text(
          category.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: category.services.map((service) {
          return ListTile(
            leading: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: service.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(17.5),
              ),
              child: Icon(
                service.icon,
                color: service.color,
                size: 18,
              ),
            ),
            title: Text(service.name),
            subtitle: Text(service.description),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Naviguer vers le paiement du service spécifique
              _showServicePayment(context, service);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentPayments(BuildContext context) {
    final recentPayments = [
      RecentPayment(
        serviceName: 'ENEO',
        amount: 15000,
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: 'Terminé',
        icon: Icons.electrical_services,
        color: Colors.yellow,
      ),
      RecentPayment(
        serviceName: 'MTN Crédit',
        amount: 2000,
        date: DateTime.now().subtract(const Duration(days: 5)),
        status: 'Terminé',
        icon: Icons.phone_android,
        color: Colors.yellow,
      ),
      RecentPayment(
        serviceName: 'Canal+',
        amount: 8500,
        date: DateTime.now().subtract(const Duration(days: 8)),
        status: 'Terminé',
        icon: Icons.tv,
        color: Colors.purple,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Paiements récents',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Voir tous les paiements
              },
              child: const Text('Voir tout'),
            ),
          ],
        )
            .animate()
            .fadeIn(delay: 600.ms, duration: 600.ms)
            .slideY(begin: -0.2, end: 0),
        
        const SizedBox(height: 16),
        
        if (recentPayments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.payment_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Aucun paiement récent',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vos paiements apparaîtront ici',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...recentPayments.asMap().entries.map((entry) {
            final index = entry.key;
            final payment = entry.value;
            return _buildRecentPaymentItem(context, payment)
                .animate()
                .fadeIn(delay: (700 + index * 100).ms, duration: 600.ms)
                .slideX(begin: 0.3, end: 0);
          }).toList(),
      ],
    );
  }

  Widget _buildRecentPaymentItem(BuildContext context, RecentPayment payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: payment.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(22.5),
          ),
          child: Icon(
            payment.icon,
            color: payment.color,
            size: 22,
          ),
        ),
        title: Text(
          payment.serviceName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _formatDate(payment.date),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '-${payment.amount.toStringAsFixed(0)} XAF',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                payment.status,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          // TODO: Voir les détails du paiement
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Aujourd\'hui';
    } else if (difference == 1) {
      return 'Hier';
    } else if (difference < 7) {
      return 'Il y a $difference jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showServicePayment(BuildContext context, PaymentService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return _buildServicePaymentSheet(context, service, scrollController);
        },
      ),
    );
  }

  Widget _buildServicePaymentSheet(BuildContext context, PaymentService service, ScrollController scrollController) {
    final amountController = TextEditingController();
    final referenceController = TextEditingController();
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: service.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  service.icon,
                  color: service.color,
                  size: 25,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      service.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Référence/Numéro
                  TextField(
                    controller: referenceController,
                    decoration: const InputDecoration(
                      labelText: 'Numéro de référence',
                      hintText: 'Ex: Numéro de compteur, téléphone...',
                      prefixIcon: Icon(Icons.tag),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Montant
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Montant (XAF)',
                      hintText: 'Saisissez le montant',
                      prefixIcon: Icon(Icons.money),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Note d'information
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Vérifiez bien les informations avant de confirmer le paiement.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Boutons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Traiter le paiement
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Paiement ${service.name} à venir'),
                      ),
                    );
                  },
                  child: const Text('Payer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PaymentOption {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  PaymentOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class ServiceCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<PaymentService> services;

  ServiceCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.services,
  });
}

class PaymentService {
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  PaymentService(this.name, this.description, this.icon, this.color);
}

class RecentPayment {
  final String serviceName;
  final double amount;
  final DateTime date;
  final String status;
  final IconData icon;
  final Color color;

  RecentPayment({
    required this.serviceName,
    required this.amount,
    required this.date,
    required this.status,
    required this.icon,
    required this.color,
  });
}