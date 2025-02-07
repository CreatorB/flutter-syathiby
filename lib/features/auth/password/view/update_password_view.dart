import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:syathiby/core/utils/router/routes.dart';
import 'package:syathiby/features/auth/login/bloc/login_bloc.dart';
import 'package:syathiby/features/auth/login/bloc/login_event.dart';
import 'package:syathiby/features/auth/login/bloc/login_state.dart';
import 'package:syathiby/features/auth/register/bloc/register_bloc.dart';
import 'package:syathiby/features/auth/register/bloc/register_state.dart';
import 'package:syathiby/features/theme/bloc/theme_bloc.dart';
import 'package:syathiby/features/theme/bloc/theme_state.dart';
import 'package:syathiby/common/components/custom_text_field.dart';
import 'package:syathiby/common/components/custom_trailing.dart';
import 'package:syathiby/generated/locale_keys.g.dart';
import 'package:syathiby/common/helpers/app_helper.dart';
import 'package:syathiby/core/models/http_response_model.dart';
import 'package:syathiby/features/auth/password/widget/update_password_button.dart';
import 'package:syathiby/common/widgets/custom_scaffold.dart';
part "update_password_view_mixin.dart";

class UpdatePasswordView extends StatefulWidget {
  const UpdatePasswordView({super.key});

  @override
  State<UpdatePasswordView> createState() => _UpdatePasswordViewState();
}

class _UpdatePasswordViewState extends State<UpdatePasswordView> with UpdatePasswordViewMixin {
  @override
  Widget build(BuildContext context) {
    final LoginBloc loginBloc = BlocProvider.of<LoginBloc>(context);
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<RegisterBloc, RegisterState>(
          builder: (context, registerState) {
            return BlocBuilder<LoginBloc, LoginState>(
              builder: (context, loginState) {
                return BlocListener<LoginBloc, LoginState>(
                  listener: (context, state) {
                    _listener(state);
                  },
                  child: PopScope(
                    canPop: !loginState.isLoading,
                    child: CustomScaffold(
                      title: LocaleKeys.new_password,
                      trailing: CustomTrailing(
                        text: LocaleKeys.cancel,
                        isLoading: loginState.isLoading,
                        onPressed: () {
                          context.go(Routes.login.path);
                        },
                      ),
                      children: [
                        const Text(LocaleKeys.enter_valid_password).tr(),
                        const SizedBox(height: 10),
                        CustomTextField(
                          textEditingController: _newPasswordTextEditingController,
                          prefixIcon: CupertinoIcons.lock,
                          placeholder: LocaleKeys.password.tr(),
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          enabled: !loginState.isLoading,
                          onSubmitted: (loginState.isLoading || registerState.message == null)
                              ? null
                              : (p0) {
                                  _updateButtonOnPressed(loginBloc: loginBloc, registerState: registerState);
                                },
                        ),
                        const SizedBox(height: 10),
                        UpdatePasswordButton(
                          isLoading: loginState.isLoading,
                          onPressed: (loginState.isLoading || registerState.message == null)
                              ? null
                              : () {
                                  _updateButtonOnPressed(loginBloc: loginBloc, registerState: registerState);
                                },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
