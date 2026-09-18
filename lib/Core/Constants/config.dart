import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:catalyst_flutter_app/Core/Constants/dimens.dart';
import 'package:catalyst_flutter_app/Core/Constants/local_cache_keys.dart';
import 'package:catalyst_flutter_app/Core/Constants/route.dart';
import 'package:catalyst_flutter_app/Core/Utils/env_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppConfig {
  static final AppConfig _singleton = AppConfig._internal();
  factory AppConfig() => _singleton;
  AppConfig._internal();

  static const envAssetPath = 'assets/.env';
  static const defaultApiBaseUrl = 'https://server.catalyst-app.org/api';
  static const defaultFeedbackFormUrl = 'https://catalyst-app.org/?page_id=339';
  static const defaultFeedbackSwipeThreshold = 100;

  String _baseURL = defaultApiBaseUrl;
  String _feedbackFormUrl = defaultFeedbackFormUrl;
  int _feedbackSwipeThreshold = defaultFeedbackSwipeThreshold;

  String get baseURL => _baseURL;
  String get feedbackFormUrl => _feedbackFormUrl;
  int get feedbackSwipeThreshold => _feedbackSwipeThreshold;

  final routes = AppRoutes();
  final dimens = Dimens();
  final colors = AppColors();
  final localCacheKeys = LocalCacheKeys();

  Future<void> loadEnv() async {
    var values = <String, String>{};
    try {
      values = parseEnv(await rootBundle.loadString(envAssetPath));
    } catch (_) {
      values = {};
    }

    final fileApiBaseUrl = values['API_BASE_URL']?.trim();
    const dartDefineApiBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (dartDefineApiBaseUrl.isNotEmpty) {
      _baseURL = dartDefineApiBaseUrl;
    } else if (fileApiBaseUrl != null && fileApiBaseUrl.isNotEmpty) {
      _baseURL = fileApiBaseUrl;
    } else {
      _baseURL = defaultApiBaseUrl;
    }

    final fileFeedbackFormUrl = values['FEEDBACK_FORM_URL']?.trim();
    _feedbackFormUrl =
        (fileFeedbackFormUrl != null && fileFeedbackFormUrl.isNotEmpty)
            ? fileFeedbackFormUrl
            : defaultFeedbackFormUrl;

    final parsedThreshold = int.tryParse(
      values['FEEDBACK_SWIPE_THRESHOLD']?.trim() ?? '',
    );
    _feedbackSwipeThreshold = parsedThreshold ?? defaultFeedbackSwipeThreshold;
  }

  @visibleForTesting
  void debugOverride({
    String? baseURL,
    String? feedbackFormUrl,
    int? feedbackSwipeThreshold,
  }) {
    if (baseURL != null) _baseURL = baseURL;
    if (feedbackFormUrl != null) _feedbackFormUrl = feedbackFormUrl;
    if (feedbackSwipeThreshold != null) {
      _feedbackSwipeThreshold = feedbackSwipeThreshold;
    }
  }
}
