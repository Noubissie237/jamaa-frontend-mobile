import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamaa_frontend_mobile/core/providers/bank_provider.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/bank_card.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/build_available_banks_section.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/build_header.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/build_quick_actions.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/build_recent_transaction_section.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/card_carousel.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/horizontal_gesture_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/dashboard_provider.dart';
import '../../../core/providers/transaction_provider.dart';
import '../../widgets/balance_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _balanceVisible = true;
  final GlobalKey scrollCardKey = GlobalKey();

  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];
  bool _showingTutorial = false;
  bool _hasCheckedTutorial = false; // Flag pour éviter les vérifications multiples

  Future<void> _checkFirstSeen() async {
    if (_showingTutorial || _hasCheckedTutorial) return;

    final dashboardProvider = context.read<DashboardProvider>();
    
    // Ne vérifier que si les données sont chargées ET qu'il y a des comptes bancaires
    if (!dashboardProvider.isLoading && dashboardProvider.bankAccounts.isNotEmpty) {
      _hasCheckedTutorial = true; // Marquer comme vérifié
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool _seen = (prefs.getBool('card_scroll_tutorial_seen') ?? false);

      if (!_seen && mounted) {
        _showingTutorial = true;
        _initTargets();
        showTutorial();
        await prefs.setBool('card_scroll_tutorial_seen', true);
      }
    }
  }

  void _onDashboardDataLoaded() {
    // Vérifier le tutoriel chaque fois que les données changent
    _checkFirstSeen();
  }

  void _checkUserVerificationStatus() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    
    // Si l'utilisateur existe et n'est pas vérifié, rafraîchir les données
    if (user != null && !user.isVerified) {
      debugPrint('👤 [DASHBOARD] Utilisateur non vérifié détecté, rafraîchissement des données...');
      authProvider.refreshUserData();
    }
  }

  void showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        print("Tutoriel des cartes terminé");
        _showingTutorial = false;
      },
      onClickTarget: (target) {
        print('Carte ${target.identify} cliquée');
      },
      onSkip: () {
        print("Tutoriel des cartes ignoré");
        _showingTutorial = false;
        return true;
      },
    );

    if (mounted) {
      tutorialCoachMark.show(context: context);
    }
  }

  void _initTargets() {
    targets = [
      TargetFocus(
        identify: "cardCarousel",
        keyTarget: scrollCardKey,
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Vos Cartes",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Faites glisser horizontalement pour naviguer entre votre carte principale JAMAA et vos différents comptes bancaires.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Indicateur de geste horizontal
                    const HorizontalGestureIndicator(
                      text: "Glissez horizontalement entre vos cartes",
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            controller.previous();
                          },
                          child: const Text(
                            "Ignorer",
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
                            foregroundColor: Colors.black,
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
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardProvider = context.read<DashboardProvider>();
      final authProvider = context.read<AuthProvider>();
      
      // Vérifier le statut de vérification utilisateur
      _checkUserVerificationStatus();
      
      // Charger les données
      dashboardProvider.loadDashboardData(userId: authProvider.currentUser!.id.toString());
      context.read<TransactionProvider>().loadTransactions(authProvider.currentUser!.id);
      
      // Ajouter un listener pour détecter quand les données sont chargées
      dashboardProvider.addListener(_onDashboardDataLoaded);
    });
  }

  @override
  void dispose() {
    // Nettoyer le listener
    try {
      context.read<DashboardProvider>().removeListener(_onDashboardDataLoaded);
    } catch (e) {
      // Ignorer si le provider n'existe plus
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec salutation
                buildHeader(context),

                const SizedBox(height: 24),

                // Carte de solde avec tutoriel
                Container(
                  key: scrollCardKey,
                  child: _buildBalanceSection(),
                ),

                const SizedBox(height: 24),

                // Actions rapides
                buildQuickActions(context),

                const SizedBox(height: 24),

                // Banques disponibles
                buildAvailableBanksSection(context),

                const SizedBox(height: 24),

                // Transactions récentes
                buildRecentTransactionSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceSection() {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        if (dashboardProvider.isLoading) {
          return Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        // Créer la liste des cartes
        List<Widget> cards = [];
        
        // Ajouter la carte principale
        cards.add(
          BalanceCard(
            balance: dashboardProvider.formattedTotalBalance,
            cardNumber: dashboardProvider.formattedAccountNumber,
            isVisible: _balanceVisible,
            onToggleVisibility: () {
              setState(() {
                _balanceVisible = !_balanceVisible;
              });
            }
          ),
        );
        
        // Ajouter les cartes bancaires
        for (final account in dashboardProvider.bankAccounts) {
          cards.add(
            BankCard(
              bankAccount: account,
              isVisible: _balanceVisible,
              onToggleVisibility: () {
                setState(() {
                  _balanceVisible = !_balanceVisible;
                });
              },
              onRecharge: () {
                // _showShareModal(context, dashboardProvider);
                // print(dashboardProvider.formattedAccountNumber);
              },
            ),
          );
        }

        return CardCarousel(
          cards: cards,
          height: 220,
          viewportFraction: 0.95,
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
      },
    );
  }

  Future<void> _refreshData() async {
    // Vérifier le statut de vérification utilisateur lors du refresh
    _checkUserVerificationStatus();
    
    await Future.wait([
      context.read<DashboardProvider>().refreshBalance(userId: context.read<AuthProvider>().currentUser!.id.toString()),
      context.read<TransactionProvider>().loadTransactions(context.read<AuthProvider>().currentUser!.id),
      context.read<BankProvider>().fetchBanks(),
    ]);
  }
}