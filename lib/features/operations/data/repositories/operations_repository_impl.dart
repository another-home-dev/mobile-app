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
    required String title,
    required String description,
    required String roomId,
  }) {
    final dto = ReportIncidentDto(
      category: category,
      title: title,
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
    required String roomId,
    required String visitorName,
    required String visitorContact,
    required String purpose,
    required String visitDate,
    required String visitTime,
  }) {
    final dto = RequestVisitorDto(
      roomId: roomId,
      visitorName: visitorName,
      visitorContact: visitorContact,
      purpose: purpose,
      visitDate: visitDate,
      visitTime: visitTime,
    );
    return _apiService.requestVisitor(dto);
  }

  @override
  Future<List<NoticeModel>> getNotices() {
    return _apiService.getNotices();
  }
}
