import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/discovery_outcome_buttons.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/stack_card_face.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/stacked_cards_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  const bob = GetCardModel(
    id: 0,
    name: 'Bob',
    description: 'Bob bio',
    affiliation: 'Lab',
    position: 'Researcher',
    location: 'Paris',
  );
  const longAda = GetCardModel(
    id: 0,
    name: 'Ada',
    description: 'Bio',
    affiliation:
        'Very long affiliation that should wrap onto more than one line in the card',
    position: 'Researcher',
    location: 'Paris',
  );

  testWidgets('discovery shows labeled outcome buttons and no skip or back',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StackedCardsScreen(users: [ada]),
      ),
    );

    expect(find.text('I know them'), findsOneWidget);
    expect(find.text('Interesting!'), findsOneWidget);
    expect(find.text('Not interested'), findsOneWidget);
    expect(find.text('I know this person'), findsNothing);
    expect(find.text("I'm not interested"), findsNothing);
    expect(find.byTooltip('Skip'), findsNothing);
    expect(find.byTooltip('Back'), findsNothing);
    expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);
    expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
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
    expect(find.text('I know them'), findsOneWidget);
  });

  testWidgets('down drag from the bio moves the card', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StackedCardsScreen(users: [ada]),
      ),
    );

    final start = tester.getTopLeft(find.byType(Card));
    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Bio')));
    await gesture.moveBy(const Offset(0, 120));
    await tester.pump();
    expect(tester.getTopLeft(find.byType(Card)).dy, closeTo(start.dy + 120, 1));

    await gesture.moveBy(const Offset(0, -120));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsOneWidget);
  });

  testWidgets('horizontal drag does not offset or dismiss the card',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StackedCardsScreen(users: [ada, bob]),
      ),
    );

    final start = tester.getTopLeft(find.byType(Card));
    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Ada')));
    await gesture.moveBy(const Offset(120, 0));
    await tester.pump();
    expect(tester.getTopLeft(find.byType(Card)).dx, closeTo(start.dx, 1));
    expect(tester.getTopLeft(find.byType(Card)).dy, closeTo(start.dy, 1));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Bob'), findsNothing);
  });

  testWidgets('arrow left and right do not move or dismiss the card',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StackedCardsScreen(users: [ada, bob]),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('Ada'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Bob'), findsNothing);
  });

  testWidgets('long affiliation wraps instead of a single ellipsis line',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StackedCardsScreen(users: [longAda]),
      ),
    );

    final text = tester.widget<Text>(find.text(longAda.affiliation));
    expect(text.maxLines, 3);
  });

  testWidgets('home actions stay visible on a short narrow viewport',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 520));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: StackedCardsScreen(users: [ada]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('I know them'), findsOneWidget);
    expect(find.text('Interesting!'), findsOneWidget);
    expect(find.text('Not interested'), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
  });

  testWidgets('home actions stay visible on a wide viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: StackedCardsScreen(users: [ada]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('I know them'), findsOneWidget);
    expect(find.text('Interesting!'), findsOneWidget);
    expect(find.text('Not interested'), findsOneWidget);
    final card = tester.getSize(find.byType(Card));
    expect(card.width, closeTo(kStackCardWidth, 1));
    expect(card.height, closeTo(kStackCardHeight, 1));
  });

  testWidgets('home actions sit against the card on a tall viewport',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: StackedCardsScreen(users: [ada]),
      ),
    );
    await tester.pumpAndSettle();

    final card = tester.getRect(find.byType(Card));
    final know = tester.getRect(find.text('I know them'));
    final interesting = tester.getRect(find.text('Interesting!'));
    final notInterested = tester.getRect(find.text('Not interested'));

    expect(card.top - know.bottom, lessThan(40));
    expect(interesting.top - card.bottom, lessThan(40));
    expect(
      notInterested.top - interesting.bottom,
      greaterThan(card.top - know.bottom),
    );
    expect(card.width, closeTo(kStackCardWidth, 1));
    expect(card.height, closeTo(kStackCardHeight, 1));
    expect(card.width / card.height, closeTo(13 / 20, 0.01));
    expect(know.top, greaterThan(80));
    expect(notInterested.bottom, lessThan(1020));
  });

  testWidgets('not interested uses muted reject red not candy red',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StackedCardsScreen(users: [ada]),
      ),
    );

    final button = tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text('Not interested'),
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(button.style?.backgroundColor?.resolve({}), kDiscoveryRejectColor);
    expect(kDiscoveryRejectColor, isNot(const Color(0xFF7A5458)));
    expect(
      kDiscoveryRejectColor,
      isNot(const Color.fromARGB(255, 226, 24, 14)),
    );
    expect(
        tester.widget<Text>(find.text('Not interested')).style?.fontSize, 16);

    final icon = tester.widget<Icon>(
      find.descendant(
        of: find.ancestor(
          of: find.text('Not interested'),
          matching: find.byType(DiscoveryOutcomeButton),
        ),
        matching: find.byIcon(Icons.expand_more),
      ),
    );
    expect(icon.size, kDiscoveryActionIconSize);
  });

  testWidgets('outcome labels are centered with icons on the right',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StackedCardsScreen(users: [ada]),
      ),
    );

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
    expectCenteredLabelWithTrailingIcon(
      'Interesting!',
      Icons.lightbulb_outline_rounded,
    );
    expectCenteredLabelWithTrailingIcon('Not interested', Icons.expand_more);
  });
}
