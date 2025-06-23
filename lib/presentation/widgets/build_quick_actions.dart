import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:jamaa_frontend_mobile/utils/utils.dart';
import 'package:jamaa_frontend_mobile/core/models/quick_action.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/build_quick_action_item.dart';

Widget buildQuickActions(BuildContext context) {
  
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
        children: actions
            .map((action) => buildQuickActionItem(context, action))
            .toList(),
      ),
    ],
  )
  .animate()
  .fadeIn(delay: 400.ms, duration: 600.ms)
  .slideY(begin: 0.3, end: 0);
}