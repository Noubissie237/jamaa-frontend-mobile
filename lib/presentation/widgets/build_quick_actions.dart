import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:jamaa_frontend_mobile/utils/utils.dart';
import 'package:jamaa_frontend_mobile/core/models/quick_action.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/build_quick_action_item.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class QuickActionsWithTutorials extends StatefulWidget {
  final Future<bool> Function()? shouldShowTutorial;
  final VoidCallback? onTutorialFinished;
  final VoidCallback? onTutorialSkipped;

  const QuickActionsWithTutorials({
    super.key,
    this.shouldShowTutorial,
    this.onTutorialFinished,
    this.onTutorialSkipped,
  });

  @override
  State<QuickActionsWithTutorials> createState() => _QuickActionsWithTutorialsState();
}

class _QuickActionsWithTutorialsState extends State<QuickActionsWithTutorials> {
  final GlobalKey transferKey = GlobalKey();
  final GlobalKey depositKey = GlobalKey();
  final GlobalKey withdrawKey = GlobalKey();

  late TutorialCoachMark tutorialCoachMark;
  bool _showingTutorial = false;

  @override
  void initState() {
    super.initState();
    // Démarrer le tutoriel après que l'interface soit construite
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowSequentialTutorial();
    });
  }

  @override
  void didUpdateWidget(QuickActionsWithTutorials oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Vérifier à nouveau quand le widget est mis à jour
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowSequentialTutorial();
    });
  }

  Future<void> _checkAndShowSequentialTutorial() async {
    if (_showingTutorial || widget.shouldShowTutorial == null) return;

    if (await widget.shouldShowTutorial!()) {
      _showingTutorial = true;
      _showSequentialTutorial();
    }
  }

  void _showSequentialTutorial() {
    // Reprendre votre code de tutoriel existant mais modifier onFinish et onSkip
    List<TargetFocus> targets = [
      _createTransferTarget(),
      _createDepositTarget(),
      _createWithdrawTarget(),
    ];

    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        print("Tutoriel séquentiel terminé");
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
        print("Tutoriel séquentiel ignoré");
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

  TargetFocus _createTransferTarget() {
    return TargetFocus(
      identify: "transfer",
      keyTarget: transferKey,
      alignSkip: Alignment.bottomRight,
      shape: ShapeLightFocus.Circle,
      radius: 15,
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
                      const Icon(
                        Icons.send,
                        color: Colors.blue,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Transférer",
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
                    "Envoyez facilement de l'argent vers :",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "• D'autres comptes JAMAA Money\n• Vos comptes bancaires",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Indicateur de progression
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      const Text(
                        "1 / 3",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.next();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Suivant",
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
    );
  }

  TargetFocus _createDepositTarget() {
    return TargetFocus(
      identify: "deposit",
      keyTarget: depositKey,
      alignSkip: Alignment.bottomRight,
      shape: ShapeLightFocus.Circle,
      radius: 15,
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
                      const Icon(
                        Icons.add_circle,
                        color: Colors.green,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Déposer",
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
                    "Rechargez vos comptes bancaires depuis votre compte JAMAA Money :",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "• Transfert instantané\n• Aucun frais\n• Suivi en temps réel",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Indicateur de progression
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          controller.previous();
                        },
                        child: const Text(
                          "Précédent",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Text(
                        "2 / 3",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.next();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Suivant",
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
    );
  }

  TargetFocus _createWithdrawTarget() {
    return TargetFocus(
      identify: "withdraw",
      keyTarget: withdrawKey,
      alignSkip: Alignment.bottomRight,
      shape: ShapeLightFocus.Circle,
      radius: 15,
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
                      const Icon(
                        Icons.remove_circle,
                        color: Colors.orange,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Retirer",
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
                    "Alimentez votre compte JAMAA Money depuis vos comptes bancaires :",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "• Recharge rapide\n• Sécurisé et fiable\n• Disponible 24h/24",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Indicateur de progression
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          controller.previous();
                        },
                        child: const Text(
                          "Précédent",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Text(
                        "3 / 3",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.next();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Terminer",
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      QuickAction(
        icon: Icons.send,
        label: 'Transférer',
        color: Colors.blue,
        onTap: () => executeActionWithVerification(context, () => context.go('/main/transfer')),
      ),
      QuickAction(
        icon: Icons.add_circle,
        label: 'Déposer',
        color: Colors.green,
        onTap: () => executeActionWithVerification(context, () => context.go('/main/deposit')),
      ),
      QuickAction(
        icon: Icons.remove_circle,
        label: 'Retirer',
        color: Colors.orange,
        onTap: () => executeActionWithVerification(context, () => context.go('/main/withdraw')),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              key: transferKey,
              child: buildQuickActionItem(context, actions[0]),
            ),
            Container(
              key: depositKey,
              child: buildQuickActionItem(context, actions[1]),
            ),
            Container(
              key: withdrawKey,
              child: buildQuickActionItem(context, actions[2]),
            ),
          ],
        ),
      ],
    )
    .animate()
    .fadeIn(delay: 400.ms, duration: 600.ms)
    .slideY(begin: 0.3, end: 0);
  }
}
