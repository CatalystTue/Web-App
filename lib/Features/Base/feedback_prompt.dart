import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/app_repo.dart';

bool shouldShowFeedbackPrompt({
  required bool introSeen,
  required bool promptSeen,
  required int swipeCount,
  required int threshold,
}) {
  if (threshold < 1 || !introSeen || promptSeen) return false;
  return swipeCount >= threshold;
}

int readDiscoverySwipeCount() {
  final value =
      AppRepo().localCache.read(AppConfig().localCacheKeys.discoverySwipeCount);
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool readFeedbackPromptSeen() {
  return AppRepo().localCache.read<bool>(
            AppConfig().localCacheKeys.feedbackPromptSeen,
          ) ??
      false;
}

bool readFeedIntroSeen() {
  return AppRepo().localCache.read<bool>(
            AppConfig().localCacheKeys.feedIntroSeen,
          ) ??
      false;
}

Future<int> incrementDiscoverySwipeCount() async {
  final next = readDiscoverySwipeCount() + 1;
  await AppRepo().localCache.write(
        AppConfig().localCacheKeys.discoverySwipeCount,
        next,
      );
  return next;
}

Future<void> markFeedbackPromptSeen() async {
  await AppRepo().localCache.write(
        AppConfig().localCacheKeys.feedbackPromptSeen,
        true,
      );
}
