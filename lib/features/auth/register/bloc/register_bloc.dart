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
        HttpResponseModel<dynamic> registerResponse = await userService.create(
          name: event.name,
          email: event.email,
          password: event.password,
        );

        // Debug response
        print('Register Response in Bloc: ${registerResponse.toString()}');

        if (registerResponse.statusCode == 200 ||
            registerResponse.statusCode == 201) {
          emit(RegisterSuccess(
              message: registerResponse.message ?? LocaleKeys.transaction_successful_subject.tr(),
              isLoading: false,
              data: registerResponse.data));
        } else {
          emit(RegisterFailed(
              message: registerResponse.message, isLoading: false));
        }
      } catch (error) {
        print('Register Error: ${error.toString()}');
        emit(RegisterFailed(
            message: 'Registration failed: ${error.toString()}',
            isLoading: false));
      }
    });
  }
}
