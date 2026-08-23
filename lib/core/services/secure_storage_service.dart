import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken,
    required String idToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'id_token', value: idToken);
    if (refreshToken != null) {
      await _storage.write(key: 'refresh_token', value: refreshToken);
    }
  }

  Future<String?> getAccessToken() => _storage.read(key: 'access_token');
  Future<String?> getIdToken() => _storage.read(key: 'id_token');
  Future<String?> getRefreshToken() => _storage.read(key: 'refresh_token');

  Future<void> clearAll() => _storage.deleteAll();

  /// Retrieve a valid (and refreshed if needed) access token.
  /// If the token is expired and cannot be refreshed, clears credentials and returns null.
  Future<String?> getValidAccessToken() async {
    String? accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();

    // If access token doesn't exist, user needs to log in
    if (accessToken == null) return null;

    // If access token is expired, attempt refresh
    if (JwtDecoder.isExpired(accessToken)) {
      if (refreshToken != null && !JwtDecoder.isExpired(refreshToken)) {
        try {
          final response = await http.post(
            Uri.parse('https://api.asgardeo.io/t/hiru616/oauth2/token'),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {
              'grant_type': 'refresh_token',
              'refresh_token': refreshToken,
              'client_id': 'wv849SSjYflfi04zRyv5W4ikiMwa',
            },
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            accessToken = data['access_token'] as String;
            
            // Update local storage with new tokens
            await _storage.write(key: 'access_token', value: accessToken);
            if (data.containsKey('refresh_token')) {
              await _storage.write(key: 'refresh_token', value: data['refresh_token'] as String);
            }
            if (data.containsKey('id_token')) {
              await _storage.write(key: 'id_token', value: data['id_token'] as String);
            }
            return accessToken;
          }
        } catch (_) {
          // Network or parsing failure, fall through to clear storage
        }
      }
      // Refresh token expired or failed -> clear session
      await clearAll();
      return null;
    }

    return accessToken;
  }
}
