import 'package:equatable/equatable.dart';
import 'package:syathiby/features/profile/model/user_model.dart';

abstract class LoginState extends Equatable {
  final String? message;
  final bool isLoading;
  final int? statusCode;

  const LoginState({
    this.message,
    this.isLoading = false,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, isLoading, statusCode];
}

class LoginInitial extends LoginState {
  const LoginInitial() : super();
}

class LoginLoading extends LoginState {
  const LoginLoading() : super(isLoading: true);
}

class LoginSuccess extends LoginState {
  final UserModel user;

  const LoginSuccess({
    required this.user,
    String? message,
  }) : super(message: message, isLoading: false, statusCode: 200);

  @override
  List<Object?> get props => [user, message, isLoading, statusCode];
}

class LoginFailed extends LoginState {
  const LoginFailed({
    String? message,
    int? statusCode,
  }) : super(message: message, isLoading: false, statusCode: statusCode);
}