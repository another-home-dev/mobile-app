import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

// Still mock. Wiring this to real data (GET /finance/invoices/{studentId} for the
// payment fields, an Operations endpoint for complaintsCount once that service
// exists) needs a way to resolve the logged-in Asgardeo user to a backend
// Student.id first — that link doesn't exist anywhere yet, so a real studentId
// isn't available here to query with.
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
