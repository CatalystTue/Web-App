import 'package:catalyst_flutter_app/Core/Constants/config.dart';

import 'external_url_stub.dart' if (dart.library.html) 'external_url_web.dart';

class ExternalLinks {
  ExternalLinks._();

  static void open(String url) => openExternalUrl(url);

  static void openFeedbackForm() => open(AppConfig().feedbackFormUrl);
}
