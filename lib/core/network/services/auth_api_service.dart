import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../services/secure_storage_service.dart';
import '../api_client.dart';
import '../dtos/auth_models.dart';

class AuthApiService {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  AuthApiService(this._apiClient, this._secureStorage);

  /// Fetch user profile live from Asgardeo's UserInfo endpoint
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final response = await _apiClient.get(
        'https://api.asgardeo.io/t/hiru616/oauth2/userinfo',
      );
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Authenticate a user and receive a JWT token from Asgardeo
  /// POST https://api.asgardeo.io/t/hiru616/oauth2/token
  Future<AuthResponseModel> login(LoginDto loginDto) async {
    final url = Uri.parse('https://api.asgardeo.io/t/hiru616/oauth2/token');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'password',
          'username': loginDto.email,
          'password': loginDto.password,
          'client_id': 'wv849SSjYflfi04zRyv5W4ikiMwa',
          'scope': 'openid profile email',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final accessToken = data['access_token'] as String;
        final idToken = data['id_token'] as String;
        final refreshToken = data['refresh_token'] as String?;

        // Save tokens securely in device encrypted storage
        await _secureStorage.saveTokens(
          accessToken: accessToken,
          idToken: idToken,
          refreshToken: refreshToken,
        );

        // Decode the claims from the id_token JWT using jwt_decoder package
        final claims = JwtDecoder.decode(idToken);
        final userId = claims['sub'] as String? ?? 'unknown';
        final email = claims['email'] as String? ?? loginDto.email;
        
        // Extract a friendly name from claims
        String name = claims['name'] as String? ?? '';
        if (name.isEmpty) {
          final givenName = claims['given_name'] as String? ?? '';
          final familyName = claims['family_name'] as String? ?? '';
          if (givenName.isNotEmpty || familyName.isNotEmpty) {
            name = '$givenName $familyName'.trim();
          } else {
            name = email.split('@').first;
          }
        }

        final authResponse = AuthResponseModel(
          token: accessToken,
          userId: userId,
          email: email,
          name: name,
        );

        // Save token in the ApiClient for subsequent requests
        _apiClient.setToken(authResponse.token);
        return authResponse;
      } else {
        try {
          final errData = jsonDecode(response.body) as Map<String, dynamic>;
          final error = errData['error'] as String? ?? '';
          final description = errData['error_description'] as String? ?? '';
          
          if (error == 'invalid_grant' ||
              description.toLowerCase().contains('invalid credentials') ||
              description.toLowerCase().contains('authentication failed')) {
            throw Exception('Invalid email or password');
          } else if (response.statusCode == 403 ||
              error == 'access_denied' ||
              description.toLowerCase().contains('blocked') ||
              description.toLowerCase().contains('locked') ||
              description.toLowerCase().contains('unverified')) {
            throw Exception('Account is locked or unverified');
          }
          throw Exception(description.isNotEmpty ? description : 'Login failed');
        } catch (e) {
          if (e is FormatException || e is TypeError) {
            throw Exception('Login failed with status: ${response.statusCode}');
          }
          rethrow;
        }
      }
    } catch (e) {
      if (e is SocketException || e is HttpException || e is HandshakeException) {
        throw Exception('Network connection failed. Please check your internet connection.');
      }
      if (e is Exception) rethrow;
      throw Exception('Failed to perform authentication: $e');
    }
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
