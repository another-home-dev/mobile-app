import 'package:another_home/core/network/dtos/operations_models.dart';
import '../repositories/operations_repository.dart';

class GetVisitorsUseCase {
  final OperationsRepository repository;

  GetVisitorsUseCase(this.repository);

  Future<List<VisitorRequestModel>> call() {
    return repository.getVisitors();
  }
}
