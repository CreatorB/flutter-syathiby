import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/features/auth/login/bloc/login_event.dart';
import 'package:syathiby/features/auth/login/bloc/login_state.dart';
import 'package:syathiby/generated/locale_keys.g.dart';
import 'package:syathiby/core/models/http_response_model.dart';
import 'package:syathiby/features/profile/model/user_model.dart';
import 'package:syathiby/features/profile/service/user_service.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
 final UserService userService;

 LoginBloc({required this.userService}) : super(const LoginInitial()) {
   on<LoginButtonPressed>((event, emit) async {
     emit(const LoginLoading());
     try {
       final loginResponse = await userService.login(
         email: event.email, 
         password: event.password
       );

       LoggerUtil.debug('Login response received: ${loginResponse.statusCode}');
       LoggerUtil.debug('Login data: ${loginResponse.data}');

       if (loginResponse.statusCode == 200 && loginResponse.data != null) {
         final userData = loginResponse.data['user'];
         final token = loginResponse.data['token'];
         if (userData != null && token != null) {
           await userService.saveAuthTokenToSP(token);
           final user = UserModel.fromMap(userData);
           
           emit(LoginSuccess(
             user: user,
             message: loginResponse.message ?? 'Login successful'
           ));
         } else {
           emit(const LoginFailed(
             message: 'Invalid response data',
             statusCode: 400
           ));
         }
       } else {
         emit(LoginFailed(
           message: loginResponse.message ?? 'Login failed',
           statusCode: loginResponse.statusCode
         ));
       }
     } catch (e, stack) {
       LoggerUtil.error('Login failed', e, stack);
       emit(const LoginFailed(
         message: 'Error occurred during login',
         statusCode: 500
       ));
     }
   });

   on<LogoutButtonPressed>((event, emit) async {
     await userService.deleteAuthTokenFromSP();
     emit(const LoginInitial());
   });

   on<UpdatePasswordButtonPressed>((event, emit) async {
     emit(const LoginLoading());
     try {
       final response = await userService.updatePassword(
         userId: event.userId,
         password: event.password
       );

       if (response.statusCode == 200) {
        //  emit(UpdatePasswordSuccess(message: response.message));
       } else {
        //  emit(UpdatePasswordFailed(message: response.message));
       }
     } catch (e) {
      //  emit(UpdatePasswordFailed(message: e.toString()));
     }
   });

   on<ClearLoginData>((event, emit) => emit(const LoginInitial()));
 }
}
