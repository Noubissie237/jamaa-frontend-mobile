import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<NotificationItem> _allNotifications = [
    NotificationItem(
      id: '1',
      title: 'Transfert réussi',
      message:
          'Votre transfert de 25 000 XAF vers Marie Nguyen a été effectué avec succès.',
      type: NotificationType.transaction,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    NotificationItem(
      id: '2',
      title: 'Nouveau compte lié',
      message:
          'Votre compte Afriland First Bank a été lié avec succès à votre portefeuille JAMAA.',
      type: NotificationType.account,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationItem(
      id: '3',
      title: 'Paiement de facture',
      message: 'Votre facture ENEO de 15 000 XAF a été payée avec succès.',
      type: NotificationType.payment,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    NotificationItem(
      id: '4',
      title: 'Mise à jour de sécurité',
      message:
          'Votre code PIN a été modifié avec succès. Si ce n\'était pas vous, contactez-nous immédiatement.',
      type: NotificationType.security,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationItem(
      id: '5',
      title: 'Dépôt reçu',
      message: 'Un dépôt de 50 000 XAF a été crédité sur votre compte.',
      type: NotificationType.transaction,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    NotificationItem(
      id: '6',
      title: 'Promotion spéciale',
      message: 'Profitez de 0% de frais sur tous vos transferts ce week-end !',
      type: NotificationType.promotion,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unreadCount = _allNotifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Notifications'),
            if (unreadCount > 0)
              Text(
                '$unreadCount non lues',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Tout marquer'),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear':
                  _showClearDialog();
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: ListTile(
                      leading: Icon(Icons.clear_all),
                      title: Text('Effacer tout'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Toutes'),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Non lues'),
            const Tab(text: 'Importantes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsList(_allNotifications),
          _buildNotificationsList(
            _allNotifications.where((n) => !n.isRead).toList(),
          ),
          _buildNotificationsList(
            _allNotifications
                .where(
                  (n) =>
                      n.type == NotificationType.security ||
                      n.type == NotificationType.account,
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationItem> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune notification',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Vos notifications apparaîtront ici',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0);
    }

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification, index);
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification, int index) {
    final theme = Theme.of(context);

    return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          color:
              notification.isRead ? null : theme.primaryColor.withValues(alpha: 0.05),
          child: InkWell(
            onTap: () => _onNotificationTap(notification),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône de type
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getNotificationColor(
                        notification.type,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: _getNotificationColor(notification.type),
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Contenu
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight:
                                      notification.isRead
                                          ? FontWeight.w500
                                          : FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          notification.message,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTime(notification.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 
                                  0.5,
                                ),
                                fontSize: 11,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => _toggleReadStatus(notification),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      notification.isRead
                                          ? Icons.mark_email_unread
                                          : Icons.mark_email_read,
                                      size: 16,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap:
                                      () => _deleteNotification(notification),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.delete_outline,
                                      size: 16,
                                      color: Colors.red.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (index * 100).ms, duration: 600.ms)
        .slideX(begin: 0.3, end: 0);
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.transaction:
        return Icons.swap_horiz;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.account:
        return Icons.account_balance;
      case NotificationType.security:
        return Icons.security;

      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.transaction:
        return Colors.blue;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.account:
        return Colors.purple;
      case NotificationType.security:
        return Colors.red;
      case NotificationType.promotion:
        return Colors.orange;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  void _onNotificationTap(NotificationItem notification) {
    // Marquer comme lue si pas encore lue
    if (!notification.isRead) {
      _toggleReadStatus(notification);
    }

    // Navigation basée sur le type
    switch (notification.type) {
      case NotificationType.transaction:
      case NotificationType.payment:
        // TODO: Naviguer vers les détails de la transaction
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigation vers transaction à venir')),
        );
        break;
      case NotificationType.account:
        // TODO: Naviguer vers la gestion des comptes
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigation vers comptes à venir')),
        );
        break;
      case NotificationType.security:
        // TODO: Naviguer vers les paramètres de sécurité
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigation vers sécurité à venir')),
        );
        break;
      default:
        _showNotificationDetail(notification);
    }
  }

  void _showNotificationDetail(NotificationItem notification) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(notification.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.message),
                const SizedBox(height: 16),
                Text(
                  'Reçue le ${DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(notification.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
    );
  }

  void _toggleReadStatus(NotificationItem notification) {
    setState(() {
      notification.isRead = !notification.isRead;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          notification.isRead ? 'Marquée comme lue' : 'Marquée comme non lue',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _deleteNotification(NotificationItem notification) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Supprimer la notification'),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer cette notification ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _allNotifications.remove(notification);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification supprimée')),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _allNotifications) {
        notification.isRead = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Toutes les notifications ont été marquées comme lues'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Effacer toutes les notifications'),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer toutes les notifications ? '
              'Cette action est irréversible.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _allNotifications.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Toutes les notifications ont été supprimées',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Effacer tout'),
              ),
            ],
          ),
    );
  }

  Future<void> _refreshNotifications() async {
    // Simulation du rechargement
    await Future.delayed(const Duration(seconds: 1));

    // TODO: Recharger les notifications depuis l'API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications actualisées'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

// Modèles pour les notifications
enum NotificationType {
  transaction,
  payment,
  account,
  security,
  promotion,
  system,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  bool isRead;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });
}
