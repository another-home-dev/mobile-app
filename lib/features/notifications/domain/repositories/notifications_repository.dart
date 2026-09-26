import 'package:another_home/core/network/dtos/notification_models.dart';

abstract class NotificationsRepository {
  /// Returns an empty list if the warden hasn't registered this student yet
  /// (nothing to show rather than an error, since this backs the alerts
  /// badge shown on every dashboard load).
  Future<List<NotificationModel>> getAlerts();

  Future<void> markAsRead(String notificationId);
}
