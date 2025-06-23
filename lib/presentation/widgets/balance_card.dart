import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamaa_frontend_mobile/core/theme/app_theme.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/share_modal.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class BalanceCard extends StatefulWidget {
  final String balance;
  final bool isVisible;
  final VoidCallback? onToggleVisibility;
  final VoidCallback? onRecharge;
  final String cardNumber;
  final String accountName;
  final Future<bool> Function()? shouldShowTutorial;
  final VoidCallback? onTutorialFinished;
  final VoidCallback? onTutorialSkipped;

  const BalanceCard({
    super.key,
    required this.balance,
    this.isVisible = true,
    this.onToggleVisibility,
    this.onRecharge,
    required this.cardNumber,
    this.accountName = "JAMAA Money Account",
    this.shouldShowTutorial,
    this.onTutorialFinished,
    this.onTutorialSkipped,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  final GlobalKey shareButtonKey = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;
  bool _showingTutorial = false;
  bool _hasCheckedOnce = false; // Flag pour éviter les vérifications multiples

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowShareTutorial();
    });
  }

  @override
  void didUpdateWidget(BalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool callbacksChanged = oldWidget.shouldShowTutorial != widget.shouldShowTutorial ||
                           oldWidget.onTutorialFinished != widget.onTutorialFinished ||
                           oldWidget.onTutorialSkipped != widget.onTutorialSkipped;
    
    if (callbacksChanged && !_hasCheckedOnce) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndShowShareTutorial();
      });
    }
  }

  Future<void> _checkAndShowShareTutorial() async {
    if (_showingTutorial || widget.shouldShowTutorial == null || _hasCheckedOnce) return;

    _hasCheckedOnce = true;

    if (await widget.shouldShowTutorial!()) {
      await Future.delayed(const Duration(milliseconds: 1500));
      
      if (mounted && !_showingTutorial) {
        _showingTutorial = true;
        _showShareTutorial();
      }
    }
  }

  void _showShareTutorial() {
    List<TargetFocus> targets = [
      TargetFocus(
        identify: "shareButton",
        keyTarget: shareButtonKey,
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.RRect,
        radius: 16,
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Partager",
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
                      "Partagez facilement votre numéro de compte JAMAA Money avec d'autres utilisateurs",
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
                          _buildFeatureItem(
                            Icons.account_balance_wallet,
                            "Recevoir de l'argent",
                            "Permettez à vos proches de vous envoyer des transferts",
                          ),
                          const SizedBox(height: 12),
                          _buildFeatureItem(
                            Icons.qr_code,
                            "QR Code & Numéro",
                            "Partagez via QR code ou copiez votre numéro de compte",
                          ),
                          const SizedBox(height: 12),
                          _buildFeatureItem(
                            Icons.security,
                            "Sécurisé",
                            "Seul votre numéro de compte est partagé, en toute sécurité",
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
                            foregroundColor: AppTheme.primaryColor,
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
        print("Tutoriel bouton Partager terminé");
        _showingTutorial = false;
        
        // Appeler le callback de fin de tutoriel
        if (widget.onTutorialFinished != null) {
          widget.onTutorialFinished!();
        }
      },
      onClickTarget: (target) {
        print('Bouton ${target.identify} cliqué dans le tutoriel');
      },
      onSkip: () {
        print("Tutoriel bouton Partager ignoré");
        _showingTutorial = false;
        
        // Appeler le callback d'ignore
        if (widget.onTutorialSkipped != null) {
          widget.onTutorialSkipped!();
        }
        return true;
      },
    );

    if (mounted) {
      tutorialCoachMark.show(context: context);
    }
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
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

  void _showShareModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareModal(
        cardNumber: widget.cardNumber,
        accountName: widget.accountName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(16), 
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor, 
            AppTheme.secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
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
              Flexible(
                child: Text(
                  widget.accountName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14, 
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 40, 
                height: 40, 
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
                      fontSize: 8, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3, 
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Numéro de carte
          Text(
            widget.cardNumber,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14, 
              fontWeight: FontWeight.w400,
              letterSpacing: 1.0, 
            ),
          ),
          
          const Spacer(),
          
          // Bottom section avec solde et bouton partager
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
                        widget.isVisible ? widget.balance : '••••••••',
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24, 
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: widget.isVisible ? 0.2 : -0.2, end: 0),
                    ),
                    const SizedBox(height: 2), 
                    if (widget.onToggleVisibility != null)
                      GestureDetector(
                        onTap: widget.onToggleVisibility,
                        child: Icon(
                          widget.isVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 18, 
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12), 
              
              // Bouton Partager avec tutoriel
              GestureDetector(
                key: shareButtonKey,
                onTap: () => _showShareModal(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, 
                    vertical: 8, 
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16), 
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Partager',
                    style: TextStyle(
                      color: Color(0xFFE53E3E),
                      fontSize: 12, 
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