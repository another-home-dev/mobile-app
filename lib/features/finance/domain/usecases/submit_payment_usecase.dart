import '../repositories/finance_repository.dart';

class SubmitPaymentUseCase {
  final FinanceRepository repository;

  SubmitPaymentUseCase(this.repository);

  Future<void> call({
    required String invoiceId,
    required double amount,
    required String referenceNumber,
  }) {
    return repository.submitPayment(
      invoiceId: invoiceId,
      amount: amount,
      referenceNumber: referenceNumber,
    );
  }
}
