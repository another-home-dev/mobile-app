import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _tenant = 'hiru616';
  static const _issuer = 'https://api.asgardeo.io/t/$_tenant/oauth2/token';
  static const _clientId = 'wv849SSjYflfi04zRyv5W4ikiMwa';
  static const _redirectUrl = 'com.example.another_home://callback';

  final FlutterSecureStorage _storage;
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

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
          final response = await _appAuth.token(
            TokenRequest(
              _clientId,
              _redirectUrl,
              issuer: _issuer,
              refreshToken: refreshToken,
              grantType: 'refresh_token',
            ),
          );

          final newAccessToken = response.accessToken;
          if (newAccessToken != null) {
            accessToken = newAccessToken;
            await _storage.write(key: 'access_token', value: newAccessToken);
            if (response.refreshToken != null) {
              await _storage.write(key: 'refresh_token', value: response.refreshToken!);
            }
            if (response.idToken != null) {
              await _storage.write(key: 'id_token', value: response.idToken!);
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
