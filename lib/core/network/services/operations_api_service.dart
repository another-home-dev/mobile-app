import '../api_client.dart';
import '../dtos/auth_models.dart';
import '../dtos/operations_models.dart';
import '../../services/secure_storage_service.dart';

class OperationsApiService {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  OperationsApiService(this._apiClient, this._secureStorage);

  // --- Maintenance / Incidents ---

  /// View this student's own logged maintenance incidents (backend paginates and
  /// filters server-side by studentId; page 1 is enough for the mobile list)
  /// GET /operations/maintenance?studentId={id}
  Future<List<IncidentModel>> getIncidents() async {
    final studentId = await _secureStorage.getStudentId();
    final query = studentId != null ? '?studentId=$studentId' : '';
    final response = await _apiClient.get('/operations/maintenance$query');
    final data = (response as Map<String, dynamic>)['data'];
    if (data is List) {
      return data
          .map((json) => IncidentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Report a new maintenance issue (Student app)
  /// POST /operations/maintenance
  Future<IncidentModel> reportIncident(ReportIncidentDto reportIncidentDto) async {
    final response = await _apiClient.post(
      '/operations/maintenance',
      body: reportIncidentDto.toJson(),
    );
    return IncidentModel.fromJson(response as Map<String, dynamic>);
  }

  /// Mark an incident as resolved (Warden view)
  /// PATCH /operations/maintenance/{incidentId}
  Future<void> resolveIncident(String incidentId) async {
    await _apiClient.patch(
      '/operations/maintenance/$incidentId',
      body: {'status': 'Resolved'},
    );
  }

  // --- Visitors ---

  /// View visitor logs and pending requests (backend paginates)
  /// GET /operations/visitors
  Future<List<VisitorRequestModel>> getVisitors() async {
    final response = await _apiClient.get('/operations/visitors');
    final data = (response as Map<String, dynamic>)['data'];
    if (data is List) {
      return data
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
  /// PATCH /operations/visitors/{visitorId}
  Future<void> updateVisitorStatus(
    String visitorId,
    ApprovalDto approvalDto,
  ) async {
    await _apiClient.patch(
      '/operations/visitors/$visitorId',
      body: approvalDto.toJson(),
    );
  }

  // --- Notices ---

  /// Get all published notices and announcements (backend paginates; page 1 is enough for the mobile list)
  /// GET /operations/notices
  Future<List<NoticeModel>> getNotices() async {
    final response = await _apiClient.get('/operations/notices');
    final data = (response as Map<String, dynamic>)['data'];
    if (data is List) {
      return data
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
