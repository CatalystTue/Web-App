import 'package:catalyst_flutter_app/Core/Components/buttons_widgets.dart';
import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/digest_service.dart';
import 'package:catalyst_flutter_app/Core/Utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DigestScreen extends StatefulWidget {
  const DigestScreen({super.key});

  @override
  State<DigestScreen> createState() => _DigestScreenState();
}

class _DigestScreenState extends State<DigestScreen> {
  final DigestService _digestService = DigestService();

  bool _loading = true;
  bool _success = false;
  String _title = 'Recording your response';
  String _message = 'Please wait...';

  @override
  void initState() {
    super.initState();
    _consume();
  }

  String? _queryValue(String key) {
    final fromParameters = Get.parameters[key]?.trim();
    if (fromParameters != null && fromParameters.isNotEmpty) {
      return fromParameters;
    }
    final fromBase = Uri.base.queryParameters[key]?.trim();
    if (fromBase != null && fromBase.isNotEmpty) {
      return fromBase;
    }
    final fragment = Uri.base.fragment;
    if (fragment.contains('?')) {
      final query = fragment.substring(fragment.indexOf('?') + 1);
      final value = Uri.splitQueryString(query)[key]?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  Future<void> _consume() async {
    final token = _queryValue('token');
    final outcome = SwipeOutcome.tryParse(_queryValue('outcome'));

    if (token == null || outcome == null) {
      setState(() {
        _loading = false;
        _success = false;
        _title = 'Link not valid';
        _message =
            'This digest link is missing or invalid. Open the latest email and try again.';
      });
      return;
    }

    final response = await _digestService.consumeDigest(
      token: token,
      outcome: outcome,
    );

    if (!mounted) return;

    if (response != null && !response.containsKey('detail')) {
      setState(() {
        _loading = false;
        _success = true;
        _title = 'Thanks';
        _message =
            'We recorded your response. You can log in anytime to keep using Catalyst.';
      });
      return;
    }

    final detail = response?['detail']?.toString() ?? '';
    late final String message;
    if (detail == 'Invalid or expired token') {
      message = 'Invalid or expired token.';
    } else if (detail == 'Swipe already exists') {
      message = 'You already responded to this person.';
    } else if (detail.isNotEmpty) {
      message = detail;
    } else {
      message = 'We could not record your response. Please try again later.';
    }

    setState(() {
      _loading = false;
      _success = false;
      _title = 'Could not record response';
      _message = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig().colors.backGroundColor,
      appBar: AppBar(
        title: const Text(
          'Digest',
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
                  _loading ? 'Recording your response' : _title,
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
