import 'package:another_home/core/network/dtos/finance_models.dart';
import '../repositories/finance_repository.dart';

class GetInvoicesUseCase {
  final FinanceRepository repository;

  GetInvoicesUseCase(this.repository);

  Future<List<InvoiceModel>> call() {
    return repository.getInvoices();
  }
}
