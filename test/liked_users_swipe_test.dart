import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';
import 'package:catalyst_flutter_app/Features/liked_users/presentation/liked_users_screen.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/discovery_chrome.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/discovery_outcome_buttons.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/stack_card_face.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/stacked_cards_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  const ada = GetCardModel(
    id: 1,
    name: 'Ada',
    description: 'Ada bio',
    affiliation: 'Lab',
    position: 'Researcher',
    location: 'Paris',
  );
  const bob = GetCardModel(
    id: 2,
    name: 'Bob',
    description: 'Bob bio',
    affiliation: 'Lab',
    position: 'Researcher',
    location: 'Paris',
  );
  const cara = GetCardModel(
    id: 3,
    name: 'Cara',
    description: 'Cara bio',
    affiliation: 'Lab',
    position: 'Researcher',
    location: 'Paris',
  );
  const localAda = GetCardModel(
    id: 0,
    name: 'Ada',
    description: 'Ada bio',
    affiliation: 'Lab',
    position: 'Researcher',
    location: 'Paris',
  );
  const localBob = GetCardModel(
    id: 0,
    name: 'Bob',
    description: 'Bob bio',
    affiliation: 'Lab',
    position: 'Researcher',
    location: 'Paris',
  );

  Future<void> pumpLiked(
    WidgetTester tester,
    List<GetCardModel> users,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LikedUsersScreen(
          initialUsers: users,
        ),
      ),
    );
    await tester.pump();
  }

  Finder centerName(String name) {
    return find.descendant(
      of: find.byKey(const ValueKey('liked-center-card')),
      matching: find.text(name),
    );
  }

  IconButton chevron(WidgetTester tester, IconData icon) {
    return tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(icon),
        matching: find.byType(IconButton),
      ),
    );
  }

  testWidgets('two liked users start on the first with labeled actions',
      (tester) async {
    await pumpLiked(tester, [ada, bob]);

    expect(find.text('Liked Users'), findsNothing);
    expect(find.text('I know them'), findsOneWidget);
    expect(find.text('Not interested'), findsOneWidget);
    expect(find.text('Interesting!'), findsNothing);
    expect(find.byTooltip('Skip'), findsNothing);
    expect(find.byTooltip('Back'), findsNothing);
    expect(find.byTooltip('Remove interest'), findsNothing);
    expect(find.text('How this works'), findsNothing);
    expect(centerName('Ada'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(chevron(tester, Icons.arrow_back_ios_new).onPressed, isNull);
    expect(chevron(tester, Icons.arrow_forward_ios).onPressed, isNotNull);
  });

  testWidgets('one liked user shows dimmed chevrons and no peeks',
      (tester) async {
    await pumpLiked(tester, [ada]);

    expect(find.byType(Card), findsOneWidget);
    expect(chevron(tester, Icons.arrow_back_ios_new).onPressed, isNull);
    expect(chevron(tester, Icons.arrow_forward_ios).onPressed, isNull);
    expect(find.byTooltip('Skip'), findsNothing);
    expect(find.byTooltip('Back'), findsNothing);
  });

  testWidgets('right then left on two people returns to the first',
      (tester) async {
    await pumpLiked(tester, [ada, bob]);

    await tester.tap(find.byIcon(Icons.arrow_forward_ios));
    await tester.pumpAndSettle();
    expect(centerName('Bob'), findsOneWidget);
    expect(chevron(tester, Icons.arrow_forward_ios).onPressed, isNull);
    expect(chevron(tester, Icons.arrow_back_ios_new).onPressed, isNotNull);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();
    expect(centerName('Ada'), findsOneWidget);
    expect(chevron(tester, Icons.arrow_back_ios_new).onPressed, isNull);
    expect(chevron(tester, Icons.arrow_forward_ios).onPressed, isNotNull);
  });

  testWidgets('liked users has feed chrome without unlike', (tester) async {
    await pumpLiked(tester, [ada]);

    expect(find.byTooltip('Settings'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Liked people'), findsOneWidget);
    expect(find.byType(DiscoveryUndoLikesSwitch), findsOneWidget);
    expect(find.byIcon(Icons.lightbulb), findsOneWidget);
    expect(
      tester.getTopLeft(find.byTooltip('Liked people')).dy,
      lessThan(tester.getTopLeft(find.byTooltip('Undo')).dy),
    );
    expect(find.byTooltip('Remove interest'), findsNothing);
    expect(centerName('Ada'), findsOneWidget);
  });

  testWidgets('two people do not wrap past the last person', (tester) async {
    await pumpLiked(tester, [ada, bob]);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(centerName('Ada'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(centerName('Bob'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(centerName('Bob'), findsOneWidget);
  });

  testWidgets('three liked users wrap', (tester) async {
    await pumpLiked(tester, [ada, bob, cara]);

    expect(centerName('Ada'), findsOneWidget);
    expect(chevron(tester, Icons.arrow_back_ios_new).onPressed, isNotNull);
    expect(chevron(tester, Icons.arrow_forward_ios).onPressed, isNotNull);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(centerName('Cara'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(centerName('Ada'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(centerName('Bob'), findsOneWidget);
  });

  testWidgets('one liked user ignores left and right', (tester) async {
    await pumpLiked(tester, [ada]);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(centerName('Ada'), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
  });

  testWidgets('left swipe from the bio goes back after browsing right',
      (tester) async {
    await pumpLiked(tester, [ada, bob]);

    await tester.tap(find.byIcon(Icons.arrow_forward_ios));
    await tester.pumpAndSettle();
    expect(centerName('Bob'), findsOneWidget);

    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Bob bio')));
    await gesture.moveBy(const Offset(-120, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(centerName('Ada'), findsOneWidget);
    expect(centerName('Bob'), findsNothing);
  });

  testWidgets('short horizontal drag on a liked card snaps back',
      (tester) async {
    await pumpLiked(tester, [ada, bob]);

    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Ada')));
    await gesture.moveBy(const Offset(50, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(centerName('Ada'), findsOneWidget);
    expect(centerName('Bob'), findsNothing);
  });

  testWidgets('arrow up knows the person and drops them', (tester) async {
    await pumpLiked(tester, [localAda, localBob]);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsNothing);
    expect(centerName('Bob'), findsOneWidget);
  });

  testWidgets('arrow down marks not interested and drops them', (tester) async {
    await pumpLiked(tester, [localAda, localBob]);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsNothing);
    expect(centerName('Bob'), findsOneWidget);
  });

  testWidgets('undo is a no-op before any removal', (tester) async {
    await pumpLiked(tester, [localAda]);

    await tester.tap(find.byTooltip('Undo'));
    await tester.pumpAndSettle();

    expect(centerName('Ada'), findsOneWidget);
    expect(find.text('No liked users yet.'), findsNothing);
  });

  testWidgets('know then undo restores the person from the empty state',
      (tester) async {
    await pumpLiked(tester, [localAda]);

    await tester.tap(find.text('I know them'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsNothing);
    expect(find.text('No liked users yet.'), findsOneWidget);

    await tester.tap(find.byTooltip('Undo'));
    await tester.pumpAndSettle();

    expect(centerName('Ada'), findsOneWidget);
    expect(find.text('No liked users yet.'), findsNothing);
  });

  testWidgets('liked carousel fits a short narrow viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 520));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpLiked(tester, [ada, bob, cara]);
    await tester.pumpAndSettle();

    expect(find.text('I know them'), findsOneWidget);
    expect(find.text('Not interested'), findsOneWidget);
    expect(centerName('Ada'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
  });

  testWidgets('liked carousel fits a wide viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpLiked(tester, [ada, bob]);
    await tester.pumpAndSettle();

    expect(centerName('Ada'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    final card =
        tester.getSize(find.byKey(const ValueKey('liked-center-card')));
    expect(card.width, closeTo(kStackCardWidth, 1));
    expect(card.height, closeTo(kStackCardHeight, 1));
    expect(chevron(tester, Icons.arrow_back_ios_new).onPressed, isNull);
    expect(chevron(tester, Icons.arrow_forward_ios).onPressed, isNotNull);
    expect(
      find.byIcon(Icons.arrow_back_ios_new).hitTestable(),
      findsOneWidget,
    );
    expect(
      find.byIcon(Icons.arrow_forward_ios).hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('liked actions sit against the card on a tall viewport',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpLiked(tester, [ada]);
    await tester.pumpAndSettle();

    final card =
        tester.getRect(find.byKey(const ValueKey('liked-center-card')));
    final know = tester.getRect(find.text('I know them'));
    final notInterested = tester.getRect(find.text('Not interested'));

    expect(card.top - know.bottom, lessThan(40));
    expect(notInterested.top - card.bottom, lessThan(40));
    expect(card.width, closeTo(kStackCardWidth, 1));
    expect(card.height, closeTo(kStackCardHeight, 1));
    expect(know.top, greaterThan(80));
    expect(notInterested.bottom, lessThan(1020));
  });

  testWidgets('liked outcome labels are centered with icons on the right',
      (tester) async {
    await pumpLiked(tester, [ada]);

    void expectCenteredLabelWithTrailingIcon(String label, IconData iconData) {
      final button = find.ancestor(
        of: find.text(label),
        matching: find.byType(DiscoveryOutcomeButton),
      );
      final buttonCenter = tester.getCenter(button);
      final labelCenter = tester.getCenter(find.text(label));
      final iconFinder =
          find.descendant(of: button, matching: find.byIcon(iconData));
      final iconCenter = tester.getCenter(iconFinder);
      expect(labelCenter.dx, closeTo(buttonCenter.dx, 2));
      expect(labelCenter.dy, closeTo(buttonCenter.dy, 2));
      expect(iconCenter.dy, closeTo(buttonCenter.dy, 2));
      expect(iconCenter.dx, greaterThan(buttonCenter.dx));
      expect(tester.getSize(button).height, kDiscoveryButtonHeight);
    }

    expectCenteredLabelWithTrailingIcon('I know them', Icons.expand_less);
    expectCenteredLabelWithTrailingIcon('Not interested', Icons.expand_more);
  });

  testWidgets('narrow liked viewport keeps a large center card and crops sides',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpLiked(tester, [ada, bob, cara]);
    await tester.pumpAndSettle();

    final card =
        tester.getRect(find.byKey(const ValueKey('liked-center-card')));
    expect(card.width, closeTo(kStackCardWidth, 1));
    expect(card.height, closeTo(kStackCardHeight, 1));
    expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    expect(
      find.byIcon(Icons.arrow_back_ios_new).hitTestable(),
      findsNothing,
    );
    expect(
      find.byIcon(Icons.arrow_forward_ios).hitTestable(),
      findsNothing,
    );

    Rect painted(Finder finder) {
      final box = tester.renderObject<RenderBox>(finder);
      return MatrixUtils.transformRect(
        box.getTransformTo(null),
        Offset.zero & box.size,
      );
    }

    final nextPeek =
        painted(find.byKey(const ValueKey('liked-peek-next-1')));
    final prevPeek =
        painted(find.byKey(const ValueKey('liked-peek-prev-2')));
    expect(nextPeek.right, greaterThan(card.right + 8));
    expect(prevPeek.left, lessThan(card.left - 8));
    expect(
      tester.getSize(find.byKey(const ValueKey('liked-carousel-clip'))).width,
      closeTo(390, 1),
    );
  });

  testWidgets('home and liked cards share the same vertical origin',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: StackedCardsScreen(users: [ada]),
      ),
    );
    await tester.pumpAndSettle();
    final homeTop = tester.getTopLeft(find.byType(Card)).dy;

    await pumpLiked(tester, [ada]);
    await tester.pumpAndSettle();
    final likedTop =
        tester.getTopLeft(find.byKey(const ValueKey('liked-center-card'))).dy;

    expect(likedTop, closeTo(homeTop, 2));
  });

  testWidgets('turning the likes bulb off pops back to home', (tester) async {
    Get.reset();
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppConfig().routes.base,
        getPages: [
          GetPage(
            name: AppConfig().routes.base,
            page: () => const Scaffold(body: Text('HOME_BASE')),
          ),
          GetPage(
            name: AppConfig().routes.likedUsers,
            page: () => const LikedUsersScreen(initialUsers: [ada]),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    Get.toNamed(AppConfig().routes.likedUsers);
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsOneWidget);
    await tester.tap(find.byTooltip('Liked people'));
    await tester.pumpAndSettle();

    expect(find.text('HOME_BASE'), findsOneWidget);
    expect(find.text('Ada'), findsNothing);
  });

  testWidgets('turning the likes bulb off goes to home when it cannot pop',
      (tester) async {
    Get.reset();
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppConfig().routes.likedUsers,
        getPages: [
          GetPage(
            name: AppConfig().routes.base,
            page: () => const Scaffold(body: Text('HOME_BASE')),
          ),
          GetPage(
            name: AppConfig().routes.likedUsers,
            page: () => const LikedUsersScreen(initialUsers: [ada]),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsOneWidget);
    await tester.tap(find.byTooltip('Liked people'));
    await tester.pumpAndSettle();

    expect(find.text('HOME_BASE'), findsOneWidget);
    expect(find.text('Ada'), findsNothing);
  });
}
