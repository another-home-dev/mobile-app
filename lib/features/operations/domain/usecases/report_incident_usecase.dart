import 'package:another_home/core/network/dtos/operations_models.dart';
import '../repositories/operations_repository.dart';

class ReportIncidentUseCase {
  final OperationsRepository repository;

  ReportIncidentUseCase(this.repository);

  Future<IncidentModel> call({
    required IncidentCategory category,
    required String description,
    required String roomId,
  }) {
    return repository.reportIncident(
      category: category,
      description: description,
      roomId: roomId,
    );
  }
}
