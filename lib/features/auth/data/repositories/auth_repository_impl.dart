import '../../../../core/network/services/auth_api_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _authApiService;

  AuthRepositoryImpl(this._authApiService);

  @override
  Future<User> login() async {
    final response = await _authApiService.login();

    if (response.role != 'student') {
      await _authApiService.logout();
      throw Exception('This app is for students only. Please use the web admin console instead.');
    }

    return User(
      id: response.userId,
      name: response.name,
      email: response.email,
      role: response.role,
    );
  }
}
