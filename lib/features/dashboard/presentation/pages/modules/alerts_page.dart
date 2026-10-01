import 'package:flutter/material.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/ui_components.dart';
import 'package:another_home/core/di/service_locator.dart';
import 'package:another_home/core/network/dtos/notification_models.dart';

/// The student's personal event history — a visitor request was approved, a
/// maintenance ticket was resolved, a payment was recorded — as opposed to
/// [NoticesPage], which shows warden-wide announcements.
///
/// These are in-app only for now: the backend notification service persists
/// and logs each event but doesn't push it through FCM, so an item only shows
/// up once the student opens this screen (see another-home-notification's
/// NotificationService for the stub and the plan to swap in a real push).
class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  late Future<List<NotificationModel>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _alertsFuture = _load();
  }

  Future<List<NotificationModel>> _load() {
    return ServiceLocator.instance.getAlertsUseCase();
  }

  Future<void> _markAsRead(NotificationModel alert) async {
    if (alert.isRead) return;
    try {
      await ServiceLocator.instance.markAlertAsReadUseCase(alert.id);
      setState(() => _alertsFuture = _load());
    } catch (_) {
      // Leave it showing as unread; the student can tap again.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: FutureBuilder<List<NotificationModel>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return MessageView.error(
              title: "Couldn't load alerts",
              message: '${snapshot.error}',
              onAction: () => setState(() => _alertsFuture = _load()),
            );
          }
          final alerts = snapshot.data ?? [];
          if (alerts.isEmpty) {
            return const MessageView(
              icon: Icons.notifications_none_rounded,
              title: "You're all caught up",
              message: "You'll see updates here for visitor requests, maintenance tickets and payments.",
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              final next = _load();
              setState(() => _alertsFuture = next);
              await next;
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              itemCount: alerts.length,
              itemBuilder: (context, i) => _buildAlert(alerts[i]),
            ),
          );
        },
      ),
    );
  }

  IconData _iconFor(NotificationModel alert) {
    final t = '${alert.title} ${alert.message}'.toLowerCase();
    if (t.contains('visitor')) return Icons.group_rounded;
    if (t.contains('payment') || t.contains('invoice') || t.contains('fee')) return Icons.account_balance_wallet_rounded;
    if (t.contains('maintenance') || t.contains('complaint') || t.contains('ticket')) return Icons.handyman_rounded;
    return Icons.notifications_rounded;
  }

  Widget _buildAlert(NotificationModel alert) {
    final unread = !alert.isRead;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      color: unread ? AppColors.primarySoft.withValues(alpha: 0.55) : AppColors.surface,
      borderColor: unread ? AppColors.primary.withValues(alpha: 0.25) : AppColors.border,
      onTap: () => _markAsRead(alert),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(icon: _iconFor(alert), color: unread ? AppColors.primary : AppColors.muted, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        style: TextStyle(color: AppColors.ink, fontWeight: unread ? FontWeight.w800 : FontWeight.w600, fontSize: 15),
                      ),
                    ),
                    if (unread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(alert.message, style: const TextStyle(color: AppColors.text, fontSize: 14, height: 1.4)),
                const SizedBox(height: 8),
                Text(
                  formatShortDate(alert.createdAt),
                  style: const TextStyle(color: AppColors.faint, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
