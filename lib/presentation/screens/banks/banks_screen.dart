import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamaa_frontend_mobile/core/providers/auth_provider.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/build_accounts_summary.dart';
import 'package:jamaa_frontend_mobile/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:jamaa_frontend_mobile/core/providers/bank_provider.dart';
import 'package:jamaa_frontend_mobile/core/providers/card_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../../core/providers/dashboard_provider.dart';

class BanksScreen extends StatefulWidget {
  const BanksScreen({super.key});

  @override
  State<BanksScreen> createState() => _BanksScreenState();
}

class _BanksScreenState extends State<BanksScreen> {
  final GlobalKey addButtonKey = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;
  bool _showingTutorial = false;
  bool _hasCheckedTutorial = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser!.id;
      final userIdString = userId.toString();
      
      // Charger les données du dashboard
      context.read<DashboardProvider>().loadDashboardData(userId: userIdString);
      
      // Charger les banques et les comptes utilisateur en parallèle
      context.read<BankProvider>().fetchBanks();
      context.read<CardProvider>().fetchUserBankAccounts(userIdString);
      
      // Vérifier et montrer le tutoriel après un délai
      Future.delayed(const Duration(milliseconds: 1000), () {
        _checkAndShowAddBankTutorial();
      });
    });
  }

  Future<void> _checkAndShowAddBankTutorial() async {
    if (_showingTutorial || _hasCheckedTutorial) return;
    
    _hasCheckedTutorial = true;
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool tutorialSeen = (prefs.getBool('add_bank_tutorial_seen') ?? false);

    if (!tutorialSeen && mounted) {
      _showingTutorial = true;
      _showAddBankTutorial();
      await prefs.setBool('add_bank_tutorial_seen', true);
    }
  }

  void _showAddBankTutorial() {
    List<TargetFocus> targets = [
      TargetFocus(
        identify: "addBankButton",
        keyTarget: addButtonKey,
        alignSkip: Alignment.bottomLeft,
        shape: ShapeLightFocus.Circle,
        radius: 25,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.account_balance,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Ajouter une banque",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Connectez vos comptes bancaires pour commencer vos transactions",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildBenefitItem(
                            Icons.swap_horiz,
                            "Transactions faciles",
                            "Transférez entre vos comptes bancaires et JAMAA Money",
                          ),
                          const SizedBox(height: 12),
                          _buildBenefitItem(
                            Icons.security,
                            "Connexion sécurisée",
                            "Vos données bancaires sont protégées et chiffrées",
                          ),
                          const SizedBox(height: 12),
                          _buildBenefitItem(
                            Icons.flash_on,
                            "Instantané",
                            "Rechargez et retirez de l'argent en temps réel",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            controller.skip();
                          },
                          child: const Text(
                            "Plus tard",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            controller.next();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Compris !",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ];

    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        print("Tutoriel d'ajout de banque terminé");
        _showingTutorial = false;
      },
      onClickTarget: (target) {
        print('Bouton ${target.identify} cliqué dans le tutoriel');
      },
      onSkip: () {
        print("Tutoriel d'ajout de banque ignoré");
        _showingTutorial = false;
        return true;
      },
    );

    if (mounted) {
      tutorialCoachMark.show(context: context);
    }
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes banques'),
        centerTitle: true,
        actions: [
          IconButton(
            key: addButtonKey, // GlobalKey pour le tutoriel
            onPressed: () => executeActionWithVerification(context, () => context.go('/main/banks/add')),
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter une banque',
          ),
        ],
      ),
      body: Consumer3<DashboardProvider, BankProvider, CardProvider>(
        builder: (context, dashboardProvider, bankProvider, cardProvider, child) {
          // Vérifier l'état de chargement des trois providers
          if (dashboardProvider.isLoading || bankProvider.isLoading || cardProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Vérifier les erreurs des trois providers
          final error = dashboardProvider.error ?? bankProvider.error ?? cardProvider.error;
          if (error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dashboardProvider.error?.message ?? bankProvider.error ?? cardProvider.error ?? 'Erreur inconnue',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final userId = context.read<AuthProvider>().currentUser!.id;
                      final userIdString = userId.toString();
                      
                      dashboardProvider.loadDashboardData(userId: userIdString);
                      bankProvider.fetchBanks();
                      cardProvider.fetchUserBankAccounts(userIdString);
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final userId = context.read<AuthProvider>().currentUser!.id;
              final userIdString = userId.toString();
              
              await Future.wait([
                dashboardProvider.refreshBalance(userId: userIdString),
                bankProvider.refreshBanks(),
                cardProvider.refreshUserBankAccounts(userIdString),
              ]);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Résumé des comptes
                  buildAccountsSummary(context, dashboardProvider),
                  
                  const SizedBox(height: 32),
                  
                  // Liste des comptes bancaires (si vous voulez l'afficher)
                  if (cardProvider.hasUserBankAccounts) ...[
                    _buildUserBankAccounts(cardProvider),
                    const SizedBox(height: 32),
                  ],
                  
                  // Banques disponibles
                  _buildAvailableBanks(bankProvider, cardProvider),
                ],
              ),
            ),
          );
        },
      )
    );
  }

  Widget _buildUserBankAccounts(CardProvider cardProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mes comptes bancaires',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cardProvider.userBankAccounts.length,
          itemBuilder: (context, index) {
            final account = cardProvider.userBankAccounts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withValues(alpha: 0.15),
                  child: Text(
                    account.bankName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  account.bankName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '***${account.accountNumber.substring(account.accountNumber.length - 4)}',
                ),
                trailing: Text(
                  '${account.balance.toStringAsFixed(2)} FCFA',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAvailableBanks(BankProvider bankProvider, CardProvider cardProvider) {
    // Obtenir les banques disponibles en utilisant les deux providers
    final availableBanks = cardProvider.getAvailableBanks(bankProvider.banks);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Banques disponibles',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(delay: 600.ms, duration: 600.ms),
        
        const SizedBox(height: 8),
        
        Text(
          availableBanks.isEmpty 
            ? 'Vous êtes connecté à toutes les banques partenaires disponibles'
            : 'Connectez vos comptes de ces banques partenaires',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        )
            .animate()
            .fadeIn(delay: 650.ms, duration: 600.ms),
        
        const SizedBox(height: 16),
        
        // Afficher un message si aucune banque n'est disponible
        if (availableBanks.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Toutes les banques connectées !',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vous avez connecté tous les comptes bancaires disponibles.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          // Grille des banques disponibles
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: availableBanks.length,
            itemBuilder: (context, index) {
              final bank = availableBanks[index];
              return Card(
                child: InkWell(
                  onTap: () => context.go('/main/banks/details', extra: bank),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              bank.name.substring(0, 1),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            bank.name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: (700 + index * 100).ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0);
            },
          ),
      ],
    );
  }
}