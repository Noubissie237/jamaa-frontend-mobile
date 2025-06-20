import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:jamaa_frontend_mobile/core/models/bank.dart';
import 'package:jamaa_frontend_mobile/core/providers/bank_provider.dart';

class AvailableBanksSection extends StatefulWidget {
  const AvailableBanksSection({super.key});

  @override
  State<AvailableBanksSection> createState() => _AvailableBanksSectionState();
}

class _AvailableBanksSectionState extends State<AvailableBanksSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BankProvider>().fetchBanks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BankProvider>(
      builder: (context, bankProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, bankProvider),
            const SizedBox(height: 16),
            _buildBanksContent(context, bankProvider),
          ],
        )
            .animate()
            .fadeIn(delay: 650.ms, duration: 600.ms)
            .slideY(begin: 0.3, end: 0);
      },
    );
  }

  Widget _buildHeader(BuildContext context, BankProvider bankProvider) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Banques disponibles',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (bankProvider.banks.isNotEmpty) ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => context.go('/main/banks'),
            child: Text(
              'Voir tout',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBanksContent(BuildContext context, BankProvider bankProvider) {
    if (bankProvider.isLoading) {
      return _buildLoadingState(context);
    }

    if (bankProvider.error != null) {
      return _buildErrorState(context, bankProvider);
    }

    if (bankProvider.banks.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildBanksGrid(context, bankProvider.banks);
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(
            'Chargement des banques...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, BankProvider bankProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            'Erreur de chargement',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            bankProvider.error ?? 'Une erreur est survenue',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => bankProvider.fetchBanks(),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucune banque disponible',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'Les banques partenaires seront bientôt disponibles',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBanksGrid(BuildContext context, List<Bank> banks) {
    final banksToShow = banks.take(4).toList();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculer la largeur disponible pour éviter les débordements
        final availableWidth = constraints.maxWidth;
        final crossAxisSpacing = 12.0;
        final cardWidth = (availableWidth - crossAxisSpacing) / 2;
        final aspectRatio = cardWidth / 70; // Hauteur fixe de 70

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          ),
          itemCount: banksToShow.length,
          itemBuilder: (context, index) {
            return _buildBankCard(context, banksToShow[index], index);
          },
        );
      },
    );
  }

  Widget _buildBankCard(BuildContext context, Bank bank, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.go('/main/banks/details', extra: bank),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _buildBankIcon(context, bank),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBankInfo(context, bank),
              ),
              _buildArrowIcon(context),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (700 + index * 100).ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildBankIcon(BuildContext context, Bank bank) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Text(
                bank.name.isNotEmpty 
                    ? bank.name.substring(0, 1).toUpperCase()
                    : '?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _buildBankInfo(BuildContext context, Bank bank) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            bank.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (bank.slogan.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            bank.slogan,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ] else ...[
          const SizedBox(height: 2),
          Text(
            'Disponible',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildArrowIcon(BuildContext context) {
    return Icon(
      Icons.arrow_forward_ios,
      size: 14,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
    );
  }
}

// Widget function pour une utilisation simple
Widget buildAvailableBanksSection(BuildContext context) {
  return const AvailableBanksSection();
}