import '../entities/dashboard_summary.dart';

abstract class DashboardRepository {
  DashboardSummary getSummary();
}
