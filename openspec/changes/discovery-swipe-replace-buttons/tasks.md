## 1. Discovery chrome

- [x] 1.1 Remove the `I know this person` and `I'm not interested` buttons from `StackedCardsScreen`; verify they are gone while the card, light bulb, and Arrow Up/Down still dismiss
- [x] 1.2 Disable pointer-drag scrolling on the discovery bio so a drag that starts on the description can commit swipe; verify a drag past the threshold dismisses (up → `know`, down → `no_interest`) and a short drag snaps back

## 2. Discovery tests

- [x] 2.1 Update `test/stacked_cards_swipe_test.dart` so it asserts the labeled buttons are absent and that a vertical drag past threshold still works from the name/bio; verify `flutter test test/stacked_cards_swipe_test.dart`

## 3. Liked-users chrome

- [x] 3.1 Remove the liked-users arrow pad; verify previous/next and up/down arrow buttons are gone while Arrow keys still browse and shift the window
- [x] 3.2 Add a front-card drag that follows the finger and commits (left → previous, right → next, up/down → list window when more than 5 likes); verify a drag that starts on the bio still commits and a short drag snaps back

## 4. Liked-users tests

- [x] 4.1 Add `test/liked_users_swipe_test.dart` that injects two liked users, asserts the arrow pad is absent, and that a horizontal drag past threshold brings the other card to the front; verify `flutter test test/liked_users_swipe_test.dart`
