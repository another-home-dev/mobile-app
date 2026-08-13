import '../api_client.dart';
import '../dtos/auth_models.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

  /// Authenticate a user and receive a JWT token
  /// POST /auth/login
  Future<AuthResponseModel> login(LoginDto loginDto) async {
    final response = await _apiClient.post('/auth/login', body: loginDto.toJson());
    final authResponse = AuthResponseModel.fromJson(response as Map<String, dynamic>);
    
    // Save token in the ApiClient for subsequent requests
    _apiClient.setToken(authResponse.token);
    return authResponse;
  }

  /// Register a new student account (Pending approval)
  /// POST /auth/register
  Future<void> register(RegisterStudentDto registerStudentDto) async {
    await _apiClient.post('/auth/register', body: registerStudentDto.toJson());
  }

  /// List all pending student registrations (Warden view)
  /// GET /auth/pending-approvals
  Future<List<PendingRegistrationModel>> getPendingApprovals() async {
    final response = await _apiClient.get('/auth/pending-approvals');
    if (response is List) {
      return response
          .map((json) => PendingRegistrationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Approve or reject a student registration (Warden view)
  /// POST /auth/approve/{registrationId}
  Future<void> approveRegistration(
    String registrationId,
    ApprovalDto approvalDto,
  ) async {
    await _apiClient.post(
      '/auth/approve/$registrationId',
      body: approvalDto.toJson(),
    );
  }

  /// Clear session credentials (logout)
  void logout() {
    _apiClient.clearToken();
  }
}
