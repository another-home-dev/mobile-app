import 'package:another_home/core/network/dtos/notification_models.dart';
import '../repositories/notifications_repository.dart';

class GetAlertsUseCase {
  final NotificationsRepository repository;

  GetAlertsUseCase(this.repository);

  Future<List<NotificationModel>> call() {
    return repository.getAlerts();
  }
}
