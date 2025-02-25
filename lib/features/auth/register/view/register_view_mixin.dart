part of "register_view.dart";

mixin RegisterViewMixin on State<RegisterView> {
  late TextEditingController _nameTextEditingController;
  late TextEditingController _emailTextEditingController;
  late TextEditingController _passwordTextEditingController;
  late TextEditingController _verificationCodeTextEditingController;

  @override
  void initState() {
    super.initState();
    _nameTextEditingController = TextEditingController();
    _emailTextEditingController = TextEditingController();
    _passwordTextEditingController = TextEditingController();
    _verificationCodeTextEditingController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _nameTextEditingController.dispose();
    _emailTextEditingController.dispose();
    _passwordTextEditingController.dispose();
    _verificationCodeTextEditingController.dispose();
  }

  void _submit(RegisterBloc registerBloc) {
    HttpResponseModel httpResponseModel = AppHelper.checkRegisterForm(
      name: _nameTextEditingController.text.trim(),
      email: _emailTextEditingController.text.trim(),
      password: _passwordTextEditingController.text.trim(),
    );
    if (httpResponseModel.statusCode == 200) {
      registerBloc.add(
        RegisterButtonPressed(
          name: _nameTextEditingController.text.trim(),
          email: _emailTextEditingController.text.trim(),
          password: _passwordTextEditingController.text.trim(),
        ),
      );
    } else {
      AppHelper.showErrorMessage(
          context: context, content: httpResponseModel.message);
    }
  }

  void _listener(RegisterState state) async {
    if (state is RegisterSuccess) {
      await showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(LocaleKeys.welcome_subject.tr()),
            content: Text(LocaleKeys.welcome_text.tr()),
            actions: [
              CupertinoDialogAction(
                child: Text(LocaleKeys.ok.tr()),
                onPressed: () {
                  Navigator.pop(context);
                  context.go(Routes.login.path);
                },
              ),
            ],
          );
        },
      );
    } else if (state is RegisterFailed) {
      AppHelper.showErrorMessage(
          context: context,
          content: state.message ?? LocaleKeys.something_went_wrong.tr());
    }
  }
}
