import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:syathiby/core/utils/router/routes.dart';
import 'package:syathiby/features/auth/login/bloc/login_bloc.dart';
import 'package:syathiby/features/auth/login/bloc/login_state.dart';
import 'package:syathiby/features/profile/bloc/profile_bloc.dart';
import 'package:syathiby/features/profile/bloc/profile_event.dart';
import 'package:syathiby/features/profile/bloc/profile_state.dart';
import 'package:syathiby/features/theme/bloc/theme_bloc.dart';
import 'package:syathiby/features/theme/bloc/theme_state.dart';
import 'package:syathiby/common/components/custom_trailing.dart';
import 'package:syathiby/core/constants/app_constants.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/generated/locale_keys.g.dart';
import 'package:syathiby/common/helpers/app_helper.dart';
import 'package:syathiby/common/helpers/ui_helper.dart';
import 'package:syathiby/features/profile/widget/birthday_text_field.dart';
import 'package:syathiby/features/profile/widget/gender_text_field.dart';
import 'package:syathiby/features/profile/widget/image_dialog.dart';
import 'package:syathiby/features/profile/widget/profile_photo_widget.dart';
import 'package:syathiby/features/profile/widget/profile_text_field.dart';
import 'package:syathiby/common/widgets/custom_scaffold.dart';
import 'package:syathiby/common/widgets/unauthenticated_user_widget.dart';
part "profile_view_mixin.dart";

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> with ProfileViewMixin {
  @override
  Widget build(BuildContext context) {
    final ProfileBloc profileBloc = BlocProvider.of<ProfileBloc>(context);
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            return BlocListener<ProfileBloc, ProfileState>(
              listener: (context, profileState) {
                _listener(profileState);
              },
              child: PopScope(
                canPop: !profileState.isLoading,
                child: CustomScaffold(
                  title: LocaleKeys.profile,
                  trailing: CustomTrailing(
                    showLoadingIndicator: true,
                    text: LocaleKeys.done,
                    isLoading: profileState.user == null ? true : profileState.isLoading,
                    onPressed: () {
                      if (_checkValues() && profileState.user != null) {
                        // profileState.user!.name= firstNameTextEditingController.text.trim();
                        // profileState.user!.lastName = lastNameTextEditingController.text.trim();
                        // profileState.user!.dateOfBirth = _selectedDate!;
                        // profileState.user!.gender = _selectedGender!;
                        profileBloc.add(UpdateUser(user: profileState.user!));
                      } else {
                        AppHelper.showErrorMessage(
                            context: context, content: LocaleKeys.please_fill_in_all_fields.tr());
                      }
                    },
                  ),
                  children: [
                    profileState.user != null
                        ? Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: themeState.isDark ? ColorConstants.darkItem : ColorConstants.lightItem,
                                  borderRadius: UIHelper.borderRadius,
                                ),
                                child: Column(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CupertinoButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                showCupertinoDialog(
                                                  barrierDismissible: true,
                                                  context: context,
                                                  builder: (context) {
                                                    return ImageDialog(imageUrl: profileState.user?.photoUrl);
                                                  },
                                                );
                                              },
                                              child: ProfilePhotoWidget(imageUrl: profileState.user?.photoUrl),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                                child: const Text(LocaleKeys.enter_your_info).tr(),
                                              ),
                                            ),
                                          ],
                                        ),
                                        CupertinoButton(
                                          onPressed: () {
                                            showCupertinoDialog(
                                              barrierDismissible: true,
                                              context: context,
                                              builder: (context) {
                                                return ImageDialog(imageUrl: profileState.user?.photoUrl);
                                              },
                                            );
                                          },
                                          padding: EdgeInsets.zero,
                                          child: Text(
                                            LocaleKeys.edit,
                                            style: TextStyle(
                                              color: themeState.isDark
                                                  ? ColorConstants.darkPrimaryIcon
                                                  : ColorConstants.lightPrimaryIcon,
                                            ),
                                          ).tr(),
                                        ),
                                      ],
                                    ),
                                    CupertinoListSection(
                                      backgroundColor: Colors.transparent,
                                      margin: EdgeInsets.zero,
                                      topMargin: 10,
                                      hasLeading: false,
                                      dividerMargin: 10,
                                      decoration: BoxDecoration(
                                        color: themeState.isDark ? ColorConstants.darkItem : ColorConstants.lightItem,
                                      ),
                                      children: [
                                        ProfileTextField(
                                          textEditingController: emailTextEditingController,
                                          placeholder: LocaleKeys.email.tr(),
                                          readOnly: true,
                                          maxLength: null,
                                        ),
                                        ProfileTextField(
                                          textEditingController: firstNameTextEditingController,
                                          placeholder: LocaleKeys.first_name.tr(),
                                        ),
                                        ProfileTextField(
                                          textEditingController: lastNameTextEditingController,
                                          placeholder: LocaleKeys.last_name.tr(),
                                          textInputAction: TextInputAction.done,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              CupertinoListSection(
                                header: const Text(LocaleKeys.date_of_birth).tr(),
                                separatorColor: Colors.transparent,
                                margin: const EdgeInsets.all(0),
                                decoration: const BoxDecoration(color: Colors.transparent),
                                backgroundColor: Colors.transparent,
                                children: [
                                  BirthdayTextFieldWidget(
                                    textEditingController: birthdayTextEditingController,
                                    initialDateTime: _selectedDate,
                                    onDateTimeChanged: (date) {
                                      _selectedDate = date;
                                      birthdayTextEditingController.text = dateFormat.format(_selectedDate!);
                                    },
                                  ),
                                ],
                              ),
                              CupertinoListSection(
                                header: const Text(LocaleKeys.gender).tr(),
                                separatorColor: Colors.transparent,
                                margin: const EdgeInsets.all(0),
                                decoration: const BoxDecoration(color: Colors.transparent),
                                backgroundColor: Colors.transparent,
                                children: [
                                  GenderTextFieldWidget(
                                    initialGender: _selectedGender,
                                    textEditingController: genderTextEditingController,
                                    onGenderChanged: (gender) {
                                      genderTextEditingController.text = AppConstants.getGender(gender);
                                      setState(() {
                                        _selectedGender = gender;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          )
                        : const UnauthenticatedUserWidget(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
