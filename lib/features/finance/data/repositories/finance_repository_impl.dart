import 'package:another_home/core/errors/student_not_registered_exception.dart';
import 'package:another_home/core/network/dtos/finance_models.dart';
import 'package:another_home/core/network/services/finance_api_service.dart';
import 'package:another_home/core/services/secure_storage_service.dart';
import '../../domain/repositories/finance_repository.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceApiService _apiService;
  final SecureStorageService _secureStorage;

  FinanceRepositoryImpl(this._apiService, this._secureStorage);

  @override
  Future<List<InvoiceModel>> getInvoices() async {
    final studentId = await _secureStorage.getStudentId();
    if (studentId == null) throw const StudentNotRegisteredException();
    return _apiService.getInvoices(studentId);
  }

  @override
  Future<void> submitPayment({
    required String invoiceId,
    required double amount,
    required String referenceNumber,
  }) {
    return _apiService.submitPayment(
      SubmitPaymentDto(invoiceId: invoiceId, amount: amount, referenceNumber: referenceNumber),
    );
  }
}
