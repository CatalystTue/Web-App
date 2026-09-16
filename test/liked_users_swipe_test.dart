import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';
import 'package:catalyst_flutter_app/Features/liked_users/presentation/liked_users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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

  testWidgets('two liked users show a single card with the shared pad',
      (tester) async {
    await pumpLiked(tester, [ada, bob]);

    expect(find.byType(Card), findsOneWidget);
    expect(find.text('Liked Users'), findsNothing);
    expect(find.byTooltip('Skip'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.byTooltip('I know this person'), findsOneWidget);
    expect(find.byTooltip("I'm not interested"), findsOneWidget);
    expect(find.text('I know this person'), findsNothing);
    expect(find.text("I'm not interested"), findsNothing);
    expect(find.text('How this works'), findsNothing);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Bob'), findsNothing);
  });

  testWidgets('one liked user keeps skip and go back on the pad',
      (tester) async {
    await pumpLiked(tester, [ada]);

    expect(find.byTooltip('Skip'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.byTooltip('I know this person'), findsOneWidget);
    expect(find.byTooltip("I'm not interested"), findsOneWidget);
  });

  testWidgets('tapping skip brings the other person forward', (tester) async {
    await pumpLiked(tester, [ada, bob]);

    await tester.tap(find.byTooltip('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Ada'), findsNothing);
    expect(find.text('Bob'), findsOneWidget);
  });

  testWidgets('liked users has feed chrome without a nav back control',
      (tester) async {
    await pumpLiked(tester, [ada]);

    expect(find.byTooltip('Settings'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Remove interest'), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
  });

  testWidgets('arrow right skip does not wrap past the last person',
      (tester) async {
    await pumpLiked(tester, [ada, bob]);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('Ada'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('Ada'), findsNothing);
    expect(find.text('Bob'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('Ada'), findsNothing);
    expect(find.text('Bob'), findsOneWidget);
  });

  testWidgets('one liked user ignores left and right', (tester) async {
    await pumpLiked(tester, [ada]);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('Ada'), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
  });

  testWidgets('left swipe from the bio goes back after skip', (tester) async {
    await pumpLiked(tester, [ada, bob]);

    await tester.tap(find.byTooltip('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Bob'), findsOneWidget);

    final start = tester.getTopLeft(find.widgetWithText(Card, 'Bob'));
    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Bob bio')));
    await gesture.moveBy(const Offset(-120, 0));
    await tester.pump();
    expect(
      tester.getTopLeft(find.widgetWithText(Card, 'Bob')).dx,
      closeTo(start.dx - 120, 1),
    );

    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Bob'), findsNothing);
  });

  testWidgets('short horizontal drag on a liked card snaps back',
      (tester) async {
    await pumpLiked(tester, [ada, bob]);

    final start = tester.getTopLeft(find.widgetWithText(Card, 'Ada'));
    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Ada')));
    await gesture.moveBy(const Offset(50, 0));
    await tester.pump();
    expect(
      tester.getTopLeft(find.widgetWithText(Card, 'Ada')).dx,
      closeTo(start.dx + 50, 1),
    );

    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Bob'), findsNothing);
  });

  testWidgets('arrow up knows the person and drops them', (tester) async {
    await pumpLiked(tester, [localAda, localBob]);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsNothing);
    expect(find.text('Bob'), findsOneWidget);
  });

  testWidgets('arrow down marks not interested and drops them', (tester) async {
    await pumpLiked(tester, [localAda, localBob]);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsNothing);
    expect(find.text('Bob'), findsOneWidget);
  });

  testWidgets('undo is a no-op before any removal', (tester) async {
    await pumpLiked(tester, [localAda]);

    await tester.tap(find.byTooltip('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('No liked users yet.'), findsNothing);
  });

  testWidgets('unlike then undo restores the person from the empty state',
      (tester) async {
    await pumpLiked(tester, [localAda]);

    await tester.tap(find.byTooltip('Remove interest'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsNothing);
    expect(find.text('No liked users yet.'), findsOneWidget);

    await tester.tap(find.byTooltip('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('No liked users yet.'), findsNothing);
  });
}
