import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;

  LoginBloc(this.loginUseCase) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(const LoginLoading());

    try {
      final user = await loginUseCase(email: event.email, password: event.password);
      emit(LoginSuccess(user));
    } catch (error) {
      emit(LoginFailure(error.toString().replaceFirst('Exception: ', '')));
    }
  }
}
