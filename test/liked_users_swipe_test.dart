import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';
import 'package:catalyst_flutter_app/Features/liked_users/presentation/liked_users_screen.dart';
import 'package:flutter/material.dart';
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

  IgnorePointer ignoreFor(WidgetTester tester, String name) {
    return tester.widget<IgnorePointer>(
      find
          .ancestor(
            of: find.text(name),
            matching: find.byType(IgnorePointer),
          )
          .first,
    );
  }

  testWidgets('liked users has no arrow pad or know/skip buttons',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LikedUsersScreen(initialUsers: [ada, bob]),
      ),
    );

    expect(find.byTooltip('Previous card'), findsNothing);
    expect(find.byTooltip('Next card'), findsNothing);
    expect(find.byTooltip('Previous in list'), findsNothing);
    expect(find.byTooltip('Next in list'), findsNothing);
    expect(find.text('I know this person'), findsNothing);
    expect(find.text("I'm not interested"), findsNothing);
    expect(find.text('Ada'), findsOneWidget);
  });

  testWidgets('right swipe from the bio brings the next card forward',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LikedUsersScreen(initialUsers: [ada, bob]),
      ),
    );

    expect(ignoreFor(tester, 'Ada').ignoring, isFalse);
    expect(ignoreFor(tester, 'Bob').ignoring, isTrue);

    final start = tester.getTopLeft(find.widgetWithText(Card, 'Ada'));
    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Ada bio')));
    await gesture.moveBy(const Offset(120, 0));
    await tester.pump();
    expect(
      tester.getTopLeft(find.widgetWithText(Card, 'Ada')).dx,
      closeTo(start.dx + 120, 1),
    );

    await gesture.up();
    await tester.pumpAndSettle();

    expect(ignoreFor(tester, 'Ada').ignoring, isTrue);
    expect(ignoreFor(tester, 'Bob').ignoring, isFalse);
  });

  testWidgets('short horizontal drag on a liked card snaps back',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LikedUsersScreen(initialUsers: [ada, bob]),
      ),
    );

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

    expect(ignoreFor(tester, 'Ada').ignoring, isFalse);
    expect(ignoreFor(tester, 'Bob').ignoring, isTrue);
  });
}
