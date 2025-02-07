part of "splash_view.dart";

mixin SplashViewMixin on State<SplashView> {
  final UserService _userService = UserService();

  Future<bool> _future(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));
    final LoginBloc loginBloc = BlocProvider.of<LoginBloc>(context);
    String? authToken = await _userService.getAuthTokenFromSP();
    LoggerUtil.debug('cekAuthToken: $authToken');
    if (authToken == null) {
      loginBloc.add(const LogoutButtonPressed());
      if (context.mounted) {
        context.go(Routes.login.path);
      }
    } else {
      LoggerUtil.debug('Token found, checking validity...');
      try {
        var response = await _userService.getUserData(token: authToken);
        LoggerUtil.debug('getuserdata response: ${response.statusCode}');
        LoggerUtil.debug('getuserdata data: ${response.data}');
        if (response.statusCode == 200) {
          final user = UserModel.fromMap(response.data);
          final profileBloc = BlocProvider.of<ProfileBloc>(context);
          profileBloc.add(SetUser(user: user));
          if (context.mounted) {
            context.go(Routes.navigation.path);
          }
        } else {
          loginBloc.add(const LogoutButtonPressed());
          if (context.mounted) {
            context.go(Routes.login.path);
          }
        }
      } catch (e) {
        loginBloc.add(const LogoutButtonPressed());
        if (context.mounted) {
          context.go(Routes.login.path);
        }
      }
    }
    return true;
  }

  bool _checkValues(UserModel userModel) {
    return userModel.name.isNotEmpty && userModel.gender != null;
  }

  void _listener(LoginState state,
      {required LoginBloc loginBloc,
      required RegisterBloc registerBloc,
      required ProfileBloc profileBloc}) {
    LoggerUtil.debug('Splash State: $state');

    if (state is LoginSuccess) {
      profileBloc.add(SetUser(user: state.user));
      registerBloc.add(const ClearRegisterData());

      Future.microtask(() {
        if (_checkValues(state.user)) {
          context.go(Routes.navigation.path);
        } else {
          context.go(Routes.profile.path);
        }
      });
    } else if (state is LoginFailed) {
      loginBloc.add(const LogoutButtonPressed());
      registerBloc.add(const ClearRegisterData());
      context.go(Routes.login.path);
      AppHelper.showErrorMessage(
          context: context, content: LocaleKeys.session_terminated.tr());
    }
  }
}
