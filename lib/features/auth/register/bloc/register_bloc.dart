import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/features/auth/register/bloc/register_event.dart';
import 'package:syathiby/features/auth/register/bloc/register_state.dart';
import 'package:syathiby/generated/locale_keys.g.dart';
import 'package:syathiby/core/models/http_response_model.dart';
import 'package:syathiby/features/profile/model/user_model.dart';
import 'package:syathiby/features/profile/service/user_service.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final UserService userService;

  RegisterBloc({required this.userService}) : super(const RegisterState()) {
    on<RegisterButtonPressed>((event, emit) async {
      emit(const RegisterState(isLoading: true));
      try {
        HttpResponseModel<dynamic> registerResponse =
            await userService.create(email: event.email, password: event.password);
        if (registerResponse.data != null) {
          HttpResponseModel<dynamic> loginResponse =
              await userService.login(email: event.email, password: event.password);
          if (loginResponse.data != null) {
            HttpResponseModel<dynamic> validateResponse = await userService.validate(token: loginResponse.data);
            await userService.saveAuthTokenToSP(loginResponse.data);
            final user = UserModel.fromMap(validateResponse.data);
            emit(RegisterSuccess(user: user, message: validateResponse.message, isLoading: false));
          } else {
            emit(RegisterState(isLoading: false, message: loginResponse.message));
          }
        } else {
          emit(RegisterState(isLoading: false, message: registerResponse.message));
        }
      } catch (error) {
        emit(RegisterFailed(message: error.toString(), isLoading: false));
      }
    });

    on<CheckButtonPressed>((event, emit) async {
      emit(const RegisterState(isLoading: true));
      try {
        HttpResponseModel<dynamic> checkResponse = await userService.check(email: event.email);
        if (checkResponse.data != null) {
          if (!checkResponse.data) {
            int? verificationCode = 0;
            emit(
              CheckSuccess(
                email: event.email,
                password: event.password,
                verificationCode: verificationCode,
                isLoading: false,
                message: checkResponse.message,
                data: checkResponse.data,
              ),
            );
          } else {
            emit(
              CheckSuccess(
                email: event.email,
                password: event.password,
                isLoading: false,
                data: checkResponse.data,
                message: checkResponse.message,
              ),
            );
          }
        }
      } catch (error) {
        emit(CheckFailed(message: error.toString(), isLoading: false, data: null));
      }
    });

    on<ForgotPasswordButtonPressed>((event, emit) async {
      emit(const RegisterState(isLoading: true));
      try {
        HttpResponseModel<dynamic> checkResponse = await userService.check(email: event.email);
        if (checkResponse.data != null) {
          if (checkResponse.data) {
            int? verificationCode = 0;
            emit(
              ForgotPasswordCheckSuccess(
                email: event.email,
                verificationCode: verificationCode,
                isLoading: false,
                data: checkResponse.data,
                message: checkResponse.message,
              ),
            );
          } else {
            emit(
              ForgotPasswordCheckFailed(
                message: checkResponse.message,
                isLoading: false,
                data: checkResponse.data,
              ),
            );
          }
        }
      } catch (error) {
        emit(CheckFailed(message: error.toString(), isLoading: false, data: null));
      }
    });

    on<ClearRegisterData>((event, emit) async {
      emit(const RegisterState());
    });
  }
}
