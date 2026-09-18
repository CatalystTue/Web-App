import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';
import 'package:catalyst_flutter_app/Features/Base/base_view.dart';
import 'package:catalyst_flutter_app/Features/Base/base_viewmodel.dart';
import 'package:catalyst_flutter_app/Features/Base/feedback_prompt.dart';
import 'package:catalyst_flutter_app/Features/liked_users/presentation/liked_users_screen.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/discovery_chrome.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'helpers/local_cache_test_helper.dart';

class _TestBaseViewModel extends BaseViewModel {
  @override
  void onInit() {}
}

void main() {
  const ada = GetCardModel(
    id: 1,
    name: 'Ada',
    description: 'Bio',
    affiliation: 'Lab',
    position: 'Researcher',
    location: 'Paris',
  );
  setUpAll(initTestLocalCache);

  setUp(() async {
    await AppRepo().localCache.clear();
    Get.reset();
    AppConfig().debugOverride(
      feedbackSwipeThreshold: AppConfig.defaultFeedbackSwipeThreshold,
    );
  });

  test('shouldShowFeedbackPrompt requires intro seen, threshold, and not seen',
      () {
    expect(
      shouldShowFeedbackPrompt(
        introSeen: true,
        promptSeen: false,
        swipeCount: 100,
        threshold: 100,
      ),
      isTrue,
    );
    expect(
      shouldShowFeedbackPrompt(
        introSeen: false,
        promptSeen: false,
        swipeCount: 100,
        threshold: 100,
      ),
      isFalse,
    );
    expect(
      shouldShowFeedbackPrompt(
        introSeen: true,
        promptSeen: true,
        swipeCount: 100,
        threshold: 100,
      ),
      isFalse,
    );
    expect(
      shouldShowFeedbackPrompt(
        introSeen: true,
        promptSeen: false,
        swipeCount: 99,
        threshold: 100,
      ),
      isFalse,
    );
    expect(
      shouldShowFeedbackPrompt(
        introSeen: true,
        promptSeen: false,
        swipeCount: 100,
        threshold: 0,
      ),
      isFalse,
    );
  });

  testWidgets('base shows feedback dialog once after the threshold',
      (tester) async {
    await AppRepo().localCache.write(
          AppConfig().localCacheKeys.feedIntroSeen,
          true,
        );
    AppConfig().debugOverride(feedbackSwipeThreshold: 1);
    final controller = _TestBaseViewModel();
    controller.model.stackUsers = [
      const GetCardModel(
        id: 0,
        name: 'Ada',
        description: 'Bio',
        affiliation: 'Lab',
        position: 'Researcher',
        location: 'Paris',
      ),
    ];
    Get.put<BaseViewModel>(controller);

    await tester.pumpWidget(const GetMaterialApp(home: AppBaseView()));
    await tester.pumpAndSettle();
    expect(find.text("We'd love your feedback"), findsNothing);

    await tester.tap(find.text('Interesting!'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(readDiscoverySwipeCount(), 1);
    await tester.pumpAndSettle();
    expect(find.text("We'd love your feedback"), findsOneWidget);

    await tester.tap(find.text('Maybe later'));
    await tester.pumpAndSettle();
    expect(find.text("We'd love your feedback"), findsNothing);
    expect(readFeedbackPromptSeen(), isTrue);
  });

  testWidgets('base does not show feedback while intro is unseen',
      (tester) async {
    AppConfig().debugOverride(feedbackSwipeThreshold: 1);
    await AppRepo().localCache.write(
          AppConfig().localCacheKeys.discoverySwipeCount,
          5,
        );
    final controller = _TestBaseViewModel();
    controller.model.stackUsers = [ada];
    Get.put<BaseViewModel>(controller);

    await tester.pumpWidget(const GetMaterialApp(home: AppBaseView()));
    await tester.pump();
    await tester.pump();

    expect(find.text('How this works'), findsOneWidget);
    expect(find.text(kFeedIntroBody), findsOneWidget);
    expect(find.textContaining('liked people page'), findsOneWidget);
    expect(find.textContaining('Tap Undo at the top right'), findsOneWidget);
    expect(find.byType(DiscoveryUndoLikesSwitch), findsOneWidget);
    expect(find.byIcon(Icons.lightbulb_outline_rounded), findsWidgets);
    expect(find.text("We'd love your feedback"), findsNothing);
  });

  testWidgets('liked users does not show the feedback dialog', (tester) async {
    await AppRepo().localCache.write(
          AppConfig().localCacheKeys.feedIntroSeen,
          true,
        );
    await AppRepo().localCache.write(
          AppConfig().localCacheKeys.discoverySwipeCount,
          100,
        );
    await tester.pumpWidget(
      const GetMaterialApp(
        home: LikedUsersScreen(initialUsers: [ada]),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text("We'd love your feedback"), findsNothing);
    expect(find.text('Ada'), findsOneWidget);
  });
}
