import '../api_client.dart';
import '../dtos/notification_models.dart';

class NotificationsApiService {
  final ApiClient _apiClient;

  NotificationsApiService(this._apiClient);

  /// Get all in-app notifications for a user
  /// GET /notifications/{userId}
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final response = await _apiClient.get('/notifications/$userId');
    if (response is List) {
      return response
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Mark a specific notification as read
  /// PATCH /notifications/{notificationId}/read
  Future<void> markAsRead(String notificationId) async {
    await _apiClient.patch('/notifications/$notificationId/read');
  }

  /// Registers this device's FCM token so the backend can push real
  /// notifications to it. Called after login and whenever the token refreshes.
  /// POST /notifications/device-token
  Future<void> registerDeviceToken(String userId, String fcmToken) async {
    await _apiClient.post('/notifications/device-token', body: {
      'userId': userId,
      'fcmToken': fcmToken,
    });
  }
}
