import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Utils/env_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseEnv reads keys, skips comments, and strips quotes', () {
    final values = parseEnv('''
# comment
API_BASE_URL=https://example.test/api
FEEDBACK_FORM_URL="https://example.test/feedback"
FEEDBACK_SWIPE_THRESHOLD=25

EMPTY=
=novalue
''');

    expect(values['API_BASE_URL'], 'https://example.test/api');
    expect(values['FEEDBACK_FORM_URL'], 'https://example.test/feedback');
    expect(values['FEEDBACK_SWIPE_THRESHOLD'], '25');
    expect(values['EMPTY'], '');
  });

  test('loadEnv reads committed assets/.env defaults', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppConfig().loadEnv();
    expect(AppConfig().baseURL, AppConfig.defaultApiBaseUrl);
    expect(AppConfig().feedbackFormUrl, AppConfig.defaultFeedbackFormUrl);
    expect(
      AppConfig().feedbackSwipeThreshold,
      AppConfig.defaultFeedbackSwipeThreshold,
    );
  });
}
