import '../repositories/notifications_repository.dart';

class MarkAlertAsReadUseCase {
  final NotificationsRepository repository;

  MarkAlertAsReadUseCase(this.repository);

  Future<void> call(String notificationId) {
    return repository.markAsRead(notificationId);
  }
}
