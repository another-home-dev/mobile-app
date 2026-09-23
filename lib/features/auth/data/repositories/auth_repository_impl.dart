import 'package:another_home/core/network/api_exceptions.dart';
import 'package:another_home/core/network/services/accommodation_api_service.dart';
import 'package:another_home/core/services/secure_storage_service.dart';
import '../../../../core/network/services/auth_api_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _authApiService;
  final AccommodationApiService _accommodationApiService;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl(
    this._authApiService,
    this._accommodationApiService,
    this._secureStorage,
  );

  @override
  Future<User> login() async {
    final response = await _authApiService.login();

    if (response.role != 'student') {
      await _authApiService.logout();
      throw Exception('This app is for students only. Please use the web admin console instead.');
    }

    // Best-effort: link this Asgardeo account to its backend Student record so
    // other screens (room, payments, notices) can query by studentId. If the
    // warden hasn't registered this student yet, just proceed without one —
    // downstream screens handle a missing studentId with a friendly message.
    try {
      final student = await _accommodationApiService.getCurrentStudent();
      await _secureStorage.saveStudentId(student.id);
    } on NotFoundException {
      // Not registered by a warden yet — not fatal to login.
    } catch (_) {
      // Any other failure (network hiccup, etc.) shouldn't block login either.
    }

    return User(
      id: response.userId,
      name: response.name,
      email: response.email,
      role: response.role,
    );
  }
}
