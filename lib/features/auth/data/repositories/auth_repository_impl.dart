import '../../../../core/network/dtos/auth_models.dart';
import '../../../../core/network/services/auth_api_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _authApiService;

  AuthRepositoryImpl(this._authApiService);

  @override
  Future<User> login({required String email, required String password}) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Email and password cannot be empty');
    }

    final loginDto = LoginDto(email: email.trim(), password: password);
    final response = await _authApiService.login(loginDto);

    return User(
      id: response.userId,
      name: response.name,
      email: response.email,
    );
  }
}
