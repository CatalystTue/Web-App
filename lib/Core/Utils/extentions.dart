import 'package:catalyst_flutter_app/Core/Utils/enum.dart';

String toCamelCase(String text) {
  if (text.isEmpty) {
    return text;
  }
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

extension UserStatusExtensionFeedback on UserStatus {
  int toLocalCacheInt() {
    switch (this) {
      case UserStatus.loggedIn:
        return 1;
      case UserStatus.loggedOut:
        return 2;
    }
  }
}
