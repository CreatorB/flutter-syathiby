import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syathiby/features/theme/bloc/theme_bloc.dart';
import 'package:syathiby/features/theme/bloc/theme_state.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/generated/locale_keys.g.dart';
import 'package:syathiby/common/helpers/ui_helper.dart';

class LoginButton extends StatelessWidget {
  final bool isLoading;
  final void Function()? onPressed;
  const LoginButton({super.key, this.isLoading = false, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return SizedBox(
          width: UIHelper.deviceWidth,
          child: CupertinoButton(
            color: themeState.isDark ? ColorConstants.darkPrimaryIcon : ColorConstants.lightPrimaryIcon,
            onPressed: isLoading ? null : onPressed,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            padding: const EdgeInsets.all(10),
            disabledColor: themeState.isDark ? ColorConstants.darkPrimaryIcon : ColorConstants.lightPrimaryIcon,
            pressedOpacity: 0.5,
            child: isLoading
                ? const CupertinoActivityIndicator(
                    color: CupertinoColors.white,
                  )
                : const Text(LocaleKeys.login).tr(),
          ),
        );
      },
    );
  }
}
