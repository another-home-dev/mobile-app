import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  @override
  DashboardSummary getSummary() {
    return const DashboardSummary(
      complaintsCount: 3,
      paymentStatus: 'Due',
      pendingAmount: 'Rs. 7,500 pending',
    );
  }
}
