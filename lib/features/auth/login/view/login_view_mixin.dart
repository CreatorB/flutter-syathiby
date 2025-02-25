part of "login_view.dart";

mixin LoginViewMixin on State<LoginView> {
  late TextEditingController _emailTextEditingController;
  late TextEditingController _passwordTextEditingController;

  @override
  void initState() {
    super.initState();
    _emailTextEditingController = TextEditingController();
    _passwordTextEditingController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailTextEditingController.dispose();
    _passwordTextEditingController.dispose();
  }

  void _showForgotPasswordModalPopup() {
    showCupertinoModalPopup(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ForgotPasswordView(
          textEditingController: _emailTextEditingController,
          forgotPasswordListener: _forgotPasswordListener,
        );
      },
    );
  }

  void _forgotPasswordListener(RegisterState state) async {
    if (state is ForgotPasswordCheckSuccess) {
      if (state.data != null && state.data!) {
        if (state.verificationCode != null) {
          context.go(Routes.verify.path);
        }
      }
    } else if (state is ForgotPasswordCheckFailed) {
      AppHelper.showErrorMessage(
          context: context, content: LocaleKeys.non_existent_user_message.tr());
    } else if (state is CheckFailed) {
      AppHelper.showErrorMessage(
          context: context, content: LocaleKeys.something_went_wrong.tr());
    }
  }

void _listener(LoginState state) {
  if (state is LoginSuccess) {
    LoggerUtil.debug('Login Success, redirecting to home...');
    final ProfileBloc profileBloc = BlocProvider.of<ProfileBloc>(context);
    profileBloc.add(SetUser(user: state.user));
    
    Future.microtask(() {
      context.go(Routes.navigation.path);
    });
  } else if (state is LoginFailed) {
    if (state.statusCode == 401) {
      AppHelper.showErrorMessage(
        context: context, 
        content: state.message ?? LocaleKeys.check_your_information.tr()
      );
    } else {
      AppHelper.showErrorMessage(
        context: context, 
        content: state.message ?? LocaleKeys.something_went_wrong.tr()
      );
    }
  }
}

  void _submit(LoginBloc loginBloc) {
    final email = _emailTextEditingController.text.trim();
    final password = _passwordTextEditingController.text.trim();

    // Debug print untuk input
    print('Submitting - Email: $email, Password length: ${password.length}');

    HttpResponseModel httpResponseModel = AppHelper.checkEmailAndPassword(
      email: email,
      password: password,
    );

    if (httpResponseModel.statusCode == 200) {
      loginBloc.add(
        LoginButtonPressed(
          email: email,
          password: password,
        ),
      );
    } else {
      print('Validation Error: ${httpResponseModel.message}');
      AppHelper.showErrorMessage(
          context: context,
          content: httpResponseModel.message ?? LocaleKeys.check_your_information.tr());
    }
  }
}
