import 'package:flutter/material.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/glass_card.dart';
import 'package:another_home/core/theme/glass_background.dart';
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

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Alerts'),
        centerTitle: true,
      ),
      body: GlassBackground(
        child: FutureBuilder<List<NotificationModel>>(
          future: _alertsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load alerts: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.red),
                ),
              );
            }
            final alerts = snapshot.data ?? [];
            if (alerts.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    "No alerts yet. You'll see updates here for visitor requests, "
                    'maintenance tickets and payments.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(24),
              children: alerts.map(_buildAlertItem).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAlertItem(NotificationModel alert) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      color: AppColors.surface.withValues(alpha: 0.5),
      borderColor: alert.isRead
          ? AppColors.text.withValues(alpha: 0.08)
          : AppColors.primary.withValues(alpha: 0.35),
      onTap: () => _markAsRead(alert),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!alert.isRead)
            Container(
              margin: const EdgeInsets.only(top: 6, right: 12),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: alert.isRead ? FontWeight.w500 : FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Text(_formatDate(alert.createdAt), style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(alert.message, style: const TextStyle(color: AppColors.muted, fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
