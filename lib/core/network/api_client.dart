import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_exceptions.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _client;
  String? _jwtToken;

  ApiClient({
    this.baseUrl = 'https://api.anotherhome.lk',
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Set the JWT Token for subsequent authenticated requests
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
      headers['Authorization'] = 'Bearer $_jwtToken';
    }
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  Future<dynamic> get(String path, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final response = await _client.get(uri, headers: _headers(headers));
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException('Failed to perform GET request: ${e.toString()}');
    }
  }

  Future<dynamic> post(String path, {dynamic body, Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$path');
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

  Future<dynamic> patch(String path, {dynamic body, Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$path');
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
