import 'package:another_home/core/network/dtos/notification_models.dart';
import 'package:another_home/core/network/services/notifications_api_service.dart';
import 'package:another_home/core/services/secure_storage_service.dart';
import '../../domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsApiService _apiService;
  final SecureStorageService _secureStorage;

  NotificationsRepositoryImpl(this._apiService, this._secureStorage);

  @override
  Future<List<NotificationModel>> getAlerts() async {
    final studentId = await _secureStorage.getStudentId();
    if (studentId == null) return [];
    return _apiService.getNotifications(studentId);
  }

  @override
  Future<void> markAsRead(String notificationId) {
    return _apiService.markAsRead(notificationId);
  }
}
