import 'package:another_home/core/network/dtos/operations_models.dart';
import '../repositories/operations_repository.dart';

class GetIncidentsUseCase {
  final OperationsRepository repository;

  GetIncidentsUseCase(this.repository);

  Future<List<IncidentModel>> call() {
    return repository.getIncidents();
  }
}
