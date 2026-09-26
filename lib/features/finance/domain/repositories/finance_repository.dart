import 'package:another_home/core/network/dtos/finance_models.dart';

abstract class FinanceRepository {
  /// Throws [StudentNotRegisteredException] if the warden hasn't registered
  /// this student yet.
  Future<List<InvoiceModel>> getInvoices();

  Future<void> submitPayment({
    required String invoiceId,
    required double amount,
    required String referenceNumber,
  });
}
