import 'package:catalyst_flutter_app/Core/Constants/config.dart';
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
      backgroundColor: AppConfig().colors.primaryColor,
      appBar: AppBar(
        title: const Text('Email Verification'),
        backgroundColor: AppConfig().colors.darkYellow,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_loading) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                ] else ...[
                  Icon(
                    _success ? Icons.check_circle : Icons.error,
                    color: _success ? Colors.green : Colors.red,
                    size: 56,
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                // if (!_loading)
                //   ElevatedButton(
                //     onPressed: () => Get.offAllNamed(AppConfig().routes.auth),
                //     child: const Text('Go to Login'),
                //   ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
