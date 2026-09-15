import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/stacked_cards_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ada = GetCardModel(
    id: 0,
    name: 'Ada',
    description: 'Bio',
    affiliation: 'Lab',
    position: 'Researcher',
    location: 'Paris',
  );

  testWidgets('discovery keeps know and skip buttons', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StackedCardsScreen(users: [ada]),
      ),
    );

    expect(find.text('I know this person'), findsOneWidget);
    expect(find.text("I'm not interested"), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
  });

  testWidgets('short vertical drag on the card snaps back', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StackedCardsScreen(users: [ada]),
      ),
    );

    final start = tester.getTopLeft(find.byType(Card));
    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Ada')));
    await gesture.moveBy(const Offset(0, 50));
    await tester.pump();
    expect(tester.getTopLeft(find.byType(Card)).dy, closeTo(start.dy + 50, 1));

    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('I know this person'), findsOneWidget);
  });
}
