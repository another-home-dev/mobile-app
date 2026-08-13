import '../../domain/entities/user.dart';

abstract class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final User user;

  const LoginSuccess(this.user);
}

class LoginFailure extends LoginState {
  final String message;

  const LoginFailure(this.message);
}
