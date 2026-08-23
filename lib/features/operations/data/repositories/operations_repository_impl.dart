import 'package:another_home/core/network/dtos/operations_models.dart';
import 'package:another_home/core/network/services/operations_api_service.dart';
import '../../domain/repositories/operations_repository.dart';

class OperationsRepositoryImpl implements OperationsRepository {
  final OperationsApiService _apiService;

  OperationsRepositoryImpl(this._apiService);

  @override
  Future<List<IncidentModel>> getIncidents() {
    return _apiService.getIncidents();
  }

  @override
  Future<IncidentModel> reportIncident({
    required IncidentCategory category,
    required String description,
    required String roomId,
  }) {
    final dto = ReportIncidentDto(
      category: category,
      description: description,
      roomId: roomId,
    );
    return _apiService.reportIncident(dto);
  }

  @override
  Future<List<VisitorRequestModel>> getVisitors() {
    return _apiService.getVisitors();
  }

  @override
  Future<VisitorRequestModel> requestVisitor({
    required String studentId,
    required String visitorName,
    required String relation,
    required String expectedDate,
  }) {
    final dto = RequestVisitorDto(
      studentId: studentId,
      visitorName: visitorName,
      relation: relation,
      expectedDate: expectedDate,
    );
    return _apiService.requestVisitor(dto);
  }
}
