import '../api_client.dart';
import '../dtos/auth_models.dart';
import '../dtos/operations_models.dart';

class OperationsApiService {
  final ApiClient _apiClient;

  OperationsApiService(this._apiClient);

  // --- Maintenance / Incidents ---

  /// View all logged maintenance incidents
  /// GET /operations/incidents
  Future<List<IncidentModel>> getIncidents() async {
    final response = await _apiClient.get('/operations/incidents');
    if (response is List) {
      return response
          .map((json) => IncidentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Report a new maintenance issue (Student app)
  /// POST /operations/incidents
  Future<IncidentModel> reportIncident(ReportIncidentDto reportIncidentDto) async {
    final response = await _apiClient.post(
      '/operations/incidents',
      body: reportIncidentDto.toJson(),
    );
    return IncidentModel.fromJson(response as Map<String, dynamic>);
  }

  /// Mark an incident as resolved (Warden view)
  /// PATCH /operations/incidents/{incidentId}/resolve
  Future<void> resolveIncident(String incidentId) async {
    await _apiClient.patch('/operations/incidents/$incidentId/resolve');
  }

  // --- Visitors ---

  /// View visitor logs and pending requests
  /// GET /operations/visitors
  Future<List<VisitorRequestModel>> getVisitors() async {
    final response = await _apiClient.get('/operations/visitors');
    if (response is List) {
      return response
          .map((json) => VisitorRequestModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Request a visitor entry pass (Student app)
  /// POST /operations/visitors
  Future<VisitorRequestModel> requestVisitor(RequestVisitorDto requestVisitorDto) async {
    final response = await _apiClient.post(
      '/operations/visitors',
      body: requestVisitorDto.toJson(),
    );
    return VisitorRequestModel.fromJson(response as Map<String, dynamic>);
  }

  /// Approve or reject a visitor entry (Warden view)
  /// PATCH /operations/visitors/{visitorId}/status
  Future<void> updateVisitorStatus(
    String visitorId,
    ApprovalDto approvalDto,
  ) async {
    await _apiClient.patch(
      '/operations/visitors/$visitorId/status',
      body: approvalDto.toJson(),
    );
  }

  // --- Notices ---

  /// Get all published notices and announcements
  /// GET /operations/notices
  Future<List<NoticeModel>> getNotices() async {
    final response = await _apiClient.get('/operations/notices');
    if (response is List) {
      return response
          .map((json) => NoticeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Publish a new notice (Warden view)
  /// POST /operations/notices
  Future<NoticeModel> publishNotice(CreateNoticeDto createNoticeDto) async {
    final response = await _apiClient.post(
      '/operations/notices',
      body: createNoticeDto.toJson(),
    );
    return NoticeModel.fromJson(response as Map<String, dynamic>);
  }
}
