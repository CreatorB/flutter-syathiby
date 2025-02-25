import 'package:equatable/equatable.dart';
import 'package:syathiby/features/profile/model/user_model.dart';

class RegisterState extends Equatable {
  final String? message;
  final bool isLoading;
  final dynamic data;
  const RegisterState({this.message, this.isLoading = false, this.data});

  @override
  List<Object?> get props => [isLoading, message, data];
}

class RegisterSuccess extends RegisterState {
  final dynamic data;
  final String message;

  const RegisterSuccess({
    required this.message,
    required bool isLoading,
    this.data,
  }) : super(isLoading: isLoading);

  @override
  List<Object?> get props => [isLoading, message, data];
}

class RegisterFailed extends RegisterState {
  final String? message;

  const RegisterFailed({
    required bool isLoading,
    this.message,
  }) : super(isLoading: isLoading);

  @override
  List<Object?> get props => [isLoading, message];
}

class CheckSuccess extends RegisterState {
  final String name;
  final String email;
  final String password;
  final int? verificationCode;
  const CheckSuccess({
    required this.name,
    required this.email,
    required this.password,
    this.verificationCode,
    super.message,
    super.isLoading,
    super.data,
  });

  @override
  List<Object?> get props => [message, isLoading, data];
}

class CheckFailed extends RegisterState {
  const CheckFailed({super.message, super.isLoading, super.data});

  @override
  List<Object?> get props => [message, isLoading, data];
}

class ForgotPasswordCheckSuccess extends RegisterState {
  final String email;
  final int? verificationCode;
  const ForgotPasswordCheckSuccess({
    required this.email,
    this.verificationCode,
    super.message,
    super.isLoading,
    super.data,
  });

  @override
  List<Object?> get props => [message, isLoading, data];
}

class ForgotPasswordCheckFailed extends RegisterState {
  const ForgotPasswordCheckFailed({super.message, super.isLoading, super.data});

  @override
  List<Object?> get props => [message, isLoading, data];
}
