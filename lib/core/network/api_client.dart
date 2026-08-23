import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../main.dart';
import '../../../features/auth/presentation/pages/login_page.dart';
import '../services/secure_storage_service.dart';
import 'api_exceptions.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _client;
  final SecureStorageService? _secureStorage;
  String? _jwtToken;

  ApiClient({
    String? baseUrl,
    http.Client? client,
    SecureStorageService? secureStorage,
  })  : baseUrl = baseUrl ?? _getDefaultBaseUrl(),
        _client = client ?? http.Client(),
        _secureStorage = secureStorage;

  /// Automatically resolves gateway URL based on target platform
  static String _getDefaultBaseUrl() {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3001/api/v1'; // Android Emulator -> Local Gateway
    }
    return 'http://localhost:3001/api/v1'; // iOS Simulator / Web / Desktop Gateway
  }

  /// Set the Asgardeo OIDC / JWT Token for gateway-authenticated requests
  void setToken(String? token) {
    _jwtToken = token;
  }

  /// Check if the client is currently authenticated
  bool get isAuthenticated => _jwtToken != null;

  /// Clear the token (e.g. on logout)
  void clearToken() {
    _jwtToken = null;
  }

  Map<String, String> _headers([Map<String, String>? extraHeaders]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_jwtToken != null) {
      headers['Authorization'] = 'Bearer $_jwtToken'; // Attached for Gateway validation
    }
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  Future<void> _refreshAuthTokenIfNeeded(String path) async {
    // Skip token refresh for open registration/login paths
    if (path == '/auth/login' || path == '/auth/register') {
      return;
    }

    if (_secureStorage != null) {
      final token = await _secureStorage.getValidAccessToken();
      if (token == null) {
        if (isAuthenticated) {
          _jwtToken = null;
          _triggerGlobalRedirect();
        }
        throw const UnauthorizedException('User is unauthenticated');
      }
      _jwtToken = token;
    }
  }

  void _triggerGlobalRedirect() {
    MyApp.navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Uri _buildUri(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Uri.parse(path);
    }
    return Uri.parse('$baseUrl$path');
  }

  Future<dynamic> get(String path, {Map<String, String>? headers}) async {
    await _refreshAuthTokenIfNeeded(path);
    final uri = _buildUri(path);
    try {
      final response = await _client.get(uri, headers: _headers(headers));
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to perform GET request: ${e.toString()}');
    }
  }

  Future<dynamic> post(String path, {dynamic body, Map<String, String>? headers}) async {
    await _refreshAuthTokenIfNeeded(path);
    final uri = _buildUri(path);
    try {
      final response = await _client.post(
        uri,
        headers: _headers(headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to perform POST request: ${e.toString()}');
    }
  }

  Future<dynamic> put(String path, {dynamic body, Map<String, String>? headers}) async {
    await _refreshAuthTokenIfNeeded(path);
    final uri = _buildUri(path);
    try {
      final response = await _client.put(
        uri,
        headers: _headers(headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to perform PUT request: ${e.toString()}');
    }
  }

  Future<dynamic> patch(String path, {dynamic body, Map<String, String>? headers}) async {
    await _refreshAuthTokenIfNeeded(path);
    final uri = _buildUri(path);
    try {
      final response = await _client.patch(
        uri,
        headers: _headers(headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to perform PATCH request: ${e.toString()}');
    }
  }

  Future<dynamic> delete(String path, {Map<String, String>? headers}) async {
    await _refreshAuthTokenIfNeeded(path);
    final uri = _buildUri(path);
    try {
      final response = await _client.delete(uri, headers: _headers(headers));
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to perform DELETE request: ${e.toString()}');
    }
  }

  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final bodyString = response.body;

    dynamic jsonResponse;
    if (bodyString.isNotEmpty) {
      try {
        jsonResponse = jsonDecode(bodyString);
      } catch (_) {
        jsonResponse = bodyString;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return jsonResponse;
    }

    final message = (jsonResponse is Map && jsonResponse.containsKey('message'))
        ? jsonResponse['message']?.toString() ?? 'An error occurred'
        : 'Request failed with status: $statusCode';

    switch (statusCode) {
      case 400:
        throw BadRequestException(message);
      case 401:
        _jwtToken = null;
        if (_secureStorage != null) {
          _secureStorage.clearAll();
        }
        _triggerGlobalRedirect();
        throw UnauthorizedException(message);
      case 403:
        throw ForbiddenException(message);
      case 404:
        throw NotFoundException(message);
      case 500:
        throw InternalServerErrorException(message);
      default:
        throw ApiException(message, statusCode);
    }
  }
}