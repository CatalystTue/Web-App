## Why

Discovery still shows `I know this person` and `I'm not interested` buttons. Know / skip were meant to be swipe up / swipe down only; the earlier restore added gestures but kept the buttons, so the replacement never landed. Liked-users still uses an arrow pad for the same kind of chrome.

## What Changes

- Remove the labeled know / not-interested buttons from `/base`.
- Know is swipe up (or Arrow Up); not interested is swipe down (or Arrow Down).
- Vertical drag on the discovery card SHALL commit even when the pointer starts on the bio.
- First-use intro stays swipe-based (no button names).
- Remove the liked-users arrow pad. Browse the fan with swipe left/right (or Arrow Left/Right); shift the list window with swipe up/down (or Arrow Up/Down).

## Capabilities

### New Capabilities

- (none)

### Modified Capabilities

- `matching-stack`: discovery know / skip are swipe (and keys), not labeled buttons; liked-users browse/window are swipe (and keys), not an arrow pad

## Impact

- `lib/Features/stacked_cards/presentation/stacked_cards_screen.dart`
- `lib/Features/liked_users/presentation/liked_users_screen.dart`
- `test/stacked_cards_swipe_test.dart`
- `test/liked_users_swipe_test.dart`
- Swipe POST body unchanged (`outcome`: `know` / `no_interest`)
