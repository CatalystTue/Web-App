import 'package:catalyst_flutter_app/Core/Components/buttons_widgets.dart';
import 'package:catalyst_flutter_app/Core/Components/textfields_widget.dart';
import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/auth_service.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final AuthenticationService _authService = AuthenticationService();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _repeatPasswordCtrl = TextEditingController();

  bool _tokenValid = false;
  bool _submitting = false;
  String _message = 'The reset link is invalid.';
  String? _token;

  @override
  void initState() {
    super.initState();
    final token = _tokenFromQuery();
    if (token == null) {
      _tokenValid = false;
      _message = 'The reset link is invalid.';
      return;
    }
    _token = token;
    _tokenValid = true;
  }

  String? _tokenFromQuery() {
    final fromParameters = Get.parameters['token']?.trim();
    if (fromParameters != null && fromParameters.isNotEmpty) {
      return fromParameters;
    }
    final fromBase = Uri.base.queryParameters['token']?.trim();
    if (fromBase != null && fromBase.isNotEmpty) {
      return fromBase;
    }
    final fragment = Uri.base.fragment;
    if (fragment.contains('?')) {
      final query = fragment.substring(fragment.indexOf('?') + 1);
      final token = Uri.splitQueryString(query)['token']?.trim();
      if (token != null && token.isNotEmpty) {
        return token;
      }
    }
    return null;
  }

  bool _isSuccess(Map<String, dynamic>? response) {
    return response != null && !response.containsKey('detail');
  }

  bool _isStrongPassword(String password) {
    final RegExp passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    return passwordRegex.hasMatch(password);
  }

  Future<void> _submitReset() async {
    if (_submitting || _token == null) return;

    final password = _passwordCtrl.text.trim();
    final repeatPassword = _repeatPasswordCtrl.text.trim();

    if (password.isEmpty || repeatPassword.isEmpty) {
      AppRepo().showSnackbar(
        label: 'Error',
        text: 'Please fill both password fields.',
        position: SnackPosition.TOP,
      );
      return;
    }

    if (!_isStrongPassword(password)) {
      AppRepo().showSnackbar(
        label: 'Error',
        text: 'Password is not strong enough.',
        position: SnackPosition.TOP,
      );
      return;
    }

    if (password != repeatPassword) {
      AppRepo().showSnackbar(
        label: 'Error',
        text: 'Passwords do not match.',
        position: SnackPosition.TOP,
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    final response = await _authService.resetPassword(
      token: _token!,
      password: password,
    );

    if (!mounted) return;

    setState(() {
      _submitting = false;
    });

    if (!_isSuccess(response)) {
      if (response == null) {
        AppRepo().showSnackbar(
          label: 'Error',
          text: 'Could not reset password. The link may be invalid or expired.',
          position: SnackPosition.TOP,
        );
      }
      return;
    }

    AppRepo().showSnackbar(
      label: 'Success',
      text: 'Password updated successfully. Redirecting to login...',
      position: SnackPosition.TOP,
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Get.offAllNamed(AppConfig().routes.auth);
    }
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _repeatPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppConfig().colors.backGroundColor,
      appBar: AppBar(
        title: const Text(
          'Reset Password',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        foregroundColor: AppColors().secondaryColor,
        backgroundColor: AppConfig().colors.backGroundColor,
        elevation: 0,
      ),
      body: _tokenValid
          ? SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      "The fields marked with * are mandatory",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppConfig().colors.txtColor,
                      ),
                    ),
                  ),
                  Gap(AppConfig().dimens.medium),
                  CustomTextField(
                    controller: _passwordCtrl,
                    labelText: "Password *",
                    isPassword: true,
                    secondIcon: Icons.remove_red_eye,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Could not be empty";
                      }
                      if (!_isStrongPassword(value)) {
                        return "Password is not strong";
                      }
                      return null;
                    },
                  ),
                  Gap(AppConfig().dimens.medium),
                  CustomTextField(
                    controller: _repeatPasswordCtrl,
                    labelText: "Re-enter password *",
                    isPassword: true,
                    secondIcon: Icons.remove_red_eye,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submitReset(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Could not be empty";
                      }
                      if (value != _passwordCtrl.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                ],
              ).paddingAll(AppConfig().dimens.medium),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium,
                ),
              ),
            ),
      bottomNavigationBar: _tokenValid
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconButton(
                  title: "Reset Password",
                  onTap: _submitting ? null : _submitReset,
                  txtColor: Colors.black,
                  color: AppColors().darkYellow,
                ),
              ],
            ).paddingOnly(
              left: AppConfig().dimens.medium,
              right: AppConfig().dimens.medium,
              bottom: MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom
                  : AppConfig().dimens.medium,
              top: AppConfig().dimens.small,
            )
          : null,
    );
  }
}
