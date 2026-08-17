import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:catalyst_flutter_app/Core/Components/buttons_widgets.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final AuthenticationService _authService = AuthenticationService();

  bool _loading = true;
  bool _success = false;
  String _message = 'Verifying your email...';

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    final token = Get.parameters['token'];

    if (token == null || token.isEmpty) {
      setState(() {
        _loading = false;
        _success = false;
        _message = 'Verification token is missing or invalid.';
      });
      return;
    }

    final response = await _authService.verifyEmailToken(token);

    if (!mounted) return;

    if (response != null) {
      // TODO: make sure that the Dear name is bold
      setState(() {
        _loading = false;
        _success = true;
        _message =
            'Dear ${response['name']}, your email was verified successfully. Now you are redirected to the login page.';
      });
      Future.delayed(const Duration(seconds: 3), () {
        Get.offAllNamed(AppConfig().routes.auth);
      });
      return;
    }

    setState(() {
      _loading = false;
      _success = false;
      _message = 'Verification failed. Please request a new verification link.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig().colors.backGroundColor,
      appBar: AppBar(
        title: const Text(
          'Email Verification',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppConfig().colors.backGroundColor,
        foregroundColor: AppColors().secondaryColor,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_loading) ...[
                  CircularProgressIndicator(
                    color: AppConfig().colors.primaryColor,
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  Icon(
                    _success ? Icons.check_circle : Icons.error,
                    color: _success
                        ? AppConfig().colors.greenColor
                        : AppConfig().colors.redColor,
                    size: 56,
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  _loading
                      ? 'Verifying email'
                      : _success
                          ? 'Email verified'
                          : 'Verification failed',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (!_loading) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: CustomIconButton(
                      title: 'Go to login',
                      onTap: () => Get.offAllNamed(AppConfig().routes.auth),
                      txtColor: Colors.white,
                      color: AppConfig().colors.primaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
