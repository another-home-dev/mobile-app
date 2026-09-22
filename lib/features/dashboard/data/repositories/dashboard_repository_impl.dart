import 'package:another_home/core/network/services/finance_api_service.dart';
import 'package:another_home/core/network/services/operations_api_service.dart';
import 'package:another_home/core/services/secure_storage_service.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final FinanceApiService _financeApiService;
  final OperationsApiService _operationsApiService;
  final SecureStorageService _secureStorage;

  DashboardRepositoryImpl(
    this._financeApiService,
    this._operationsApiService,
    this._secureStorage,
  );

  @override
  Future<DashboardSummary> getSummary() async {
    final studentId = await _secureStorage.getStudentId();
    if (studentId == null) {
      return const DashboardSummary(
        complaintsCount: 0,
        paymentStatus: 'N/A',
        pendingAmount: 'Not registered yet',
      );
    }

    final incidents = await _operationsApiService.getIncidents();
    final invoices = await _financeApiService.getInvoices(studentId);

    final pending = invoices.where((i) => i.status != 'Paid').toList();
    final totalPending = pending.fold<double>(0, (sum, i) => sum + i.amount);

    return DashboardSummary(
      complaintsCount: incidents.length,
      paymentStatus: pending.isEmpty ? 'Paid up' : (pending.any((i) => i.status == 'Overdue') ? 'Overdue' : 'Due'),
      pendingAmount: pending.isEmpty ? 'No pending dues' : 'Rs. ${totalPending.toStringAsFixed(0)} pending',
    );
  }
}
