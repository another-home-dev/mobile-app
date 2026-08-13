import 'package:another_home/features/auth/domain/entities/user.dart';
import 'package:another_home/features/auth/domain/repositories/auth_repository.dart';
import 'package:another_home/features/auth/domain/usecases/login_usecase.dart';
import 'package:another_home/features/auth/presentation/bloc/login_bloc.dart';
import 'package:another_home/features/auth/presentation/bloc/login_event.dart';
import 'package:another_home/features/auth/presentation/bloc/login_state.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<User> login({required String email, required String password}) async {
    return User(id: '1', name: 'Amal', email: email);
  }
}

void main() {
  group('LoginBloc', () {
    test('emits loading then success when login succeeds', () async {
      final bloc = LoginBloc(LoginUseCase(FakeAuthRepository()));
      final states = <LoginState>[];

      final subscription = bloc.stream.listen(states.add);

      bloc.add(const LoginSubmitted(email: 'student@mail.com', password: '123456'));
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(states.first, isA<LoginLoading>());
      expect(states.last, isA<LoginSuccess>());

      await subscription.cancel();
      await bloc.close();
    });
  });
}
