import '../api_client.dart';
import '../dtos/finance_models.dart';

class FinanceApiService {
  final ApiClient _apiClient;

  FinanceApiService(this._apiClient);

  /// Get all pending fee invoices for a student
  /// GET /finance/invoices/{studentId}
  Future<List<InvoiceModel>> getInvoices(String studentId) async {
    final response = await _apiClient.get('/finance/invoices/$studentId');
    if (response is List) {
      return response
          .map((json) => InvoiceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Submit a payment receipt for an invoice
  /// POST /finance/payments
  Future<void> submitPayment(SubmitPaymentDto submitPaymentDto) async {
    await _apiClient.post('/finance/payments', body: submitPaymentDto.toJson());
  }
}
