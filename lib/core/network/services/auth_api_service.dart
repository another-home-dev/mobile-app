import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../services/secure_storage_service.dart';
import '../api_client.dart';
import '../dtos/auth_models.dart';

class AuthApiService {
  static const _tenant = 'hiru616';
  static const _issuer = 'https://api.asgardeo.io/t/$_tenant/oauth2/token';
  // Must match the mobile app registration reconfigured in Asgardeo as a native/mobile
  // app with Authorization Code + PKCE enabled (see the RBAC setup plan, Phase A.5).
  static const _clientId = 'wv849SSjYflfi04zRyv5W4ikiMwa';
  static const _redirectUrl = 'com.example.another_home://callback';
  static const _scopes = ['openid', 'profile', 'email', 'roles'];

  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  AuthApiService(this._apiClient, this._secureStorage);

  /// Fetch user profile live from Asgardeo's UserInfo endpoint
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final response = await _apiClient.get(
        'https://api.asgardeo.io/t/$_tenant/oauth2/userinfo',
      );
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Signs the user in via Asgardeo's hosted login page (Authorization Code + PKCE,
  /// opened in the system browser/WebView). The same hosted page has a "Register"
  /// link, so this single entry point covers both login and student self-registration
  /// without the app ever touching a raw password.
  Future<AuthResponseModel> login() async {
    AuthorizationTokenResponse? result;
    try {
      result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUrl,
          issuer: _issuer,
          scopes: _scopes,
        ),
      );
    } catch (e) {
      throw Exception('Sign in failed or was cancelled: $e');
    }

    final accessToken = result.accessToken;
    final idToken = result.idToken;
    final refreshToken = result.refreshToken;

    if (accessToken == null || idToken == null) {
      throw Exception('Sign in did not return the expected tokens.');
    }

    await _secureStorage.saveTokens(
      accessToken: accessToken,
      idToken: idToken,
      refreshToken: refreshToken,
    );

    final claims = JwtDecoder.decode(idToken);
    final userId = claims['sub'] as String? ?? 'unknown';
    final email = claims['email'] as String? ?? '';

    String name = claims['name'] as String? ?? '';
    if (name.isEmpty) {
      final givenName = claims['given_name'] as String? ?? '';
      final familyName = claims['family_name'] as String? ?? '';
      if (givenName.isNotEmpty || familyName.isNotEmpty) {
        name = '$givenName $familyName'.trim();
      } else {
        name = email.isNotEmpty ? email.split('@').first : 'Student';
      }
    }

    _apiClient.setToken(accessToken);

    return AuthResponseModel(
      token: accessToken,
      userId: userId,
      email: email,
      name: name,
      role: _extractRole(claims),
    );
  }

  /// Asgardeo role names can come through as e.g. "Internal/student" depending on
  /// how the role claim is configured — normalize to a plain lowercase role name,
  /// skipping the default "everyone" role Asgardeo attaches to every user.
  String? _extractRole(Map<String, dynamic> claims) {
    final roles = claims['roles'];
    final roleList = roles is List ? roles : (roles == null ? <dynamic>[] : [roles]);
    for (final raw in roleList) {
      final normalized = raw.toString().split('/').last.trim().toLowerCase();
      if (normalized.isNotEmpty && normalized != 'everyone') {
        return normalized;
      }
    }
    return null;
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
  Future<void> logout() async {
    await _secureStorage.clearAll();
    _apiClient.clearToken();
  }
}
