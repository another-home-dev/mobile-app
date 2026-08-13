import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<User> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));

    if (email.trim().isEmpty || password.trim().length < 6) {
      throw Exception('Invalid credentials');
    }

    return User(
      id: '230001A',
      name: 'Amal',
      email: email.trim(),
    );
  }
}
