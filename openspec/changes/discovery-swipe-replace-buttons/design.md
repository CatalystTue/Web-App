## Context

Discovery already maps vertical drag and Arrow keys to `_dismissFrontCard` (up → `know`, down → `no_interest`). Labeled buttons still sit under the card. Liked-users browses with an arrow pad and the same keys. Card bios are `SingleChildScrollView`s, which can cancel a card-level pointer listener. See proposal.md for motivation.

## Goals / Non-Goals

**Goals:**
- Discovery buttons gone; know / skip only from vertical swipe and Arrow keys.
- Liked-users arrow pad gone; browse/window only from card swipe and Arrow keys.
- A drag that starts on the bio can still commit.

**Non-Goals:**
- Horizontal finger-swipe for interest.
- Resetting `feedIntroSeen`.

## Decisions

### Drop the discovery button column
Remove the know / skip `CustomIconButton` pair from `StackedCardsScreen`. Keep the light bulb and keyboard mapping.

**Alternative considered:** Keep buttons as a fallback — that is what already shipped and is the gap.

### Drop the liked-users arrow pad
Map swipe direction to the existing keys: left → previous, right → next, up → earlier in the list, down → later. Unlike stays light-bulb only.

**Alternative considered:** Keep arrows as a fallback — same gap as discovery.

### Card drag wins over bio (and fan) scroll drag
Disable pointer-drag scrolling (`ScrollConfiguration` with empty `dragDevices`, wheel/trackpad still scroll). Keep a card `Listener` and distance/velocity thresholds.

**Alternative considered:** Nested scroll-at-edges then swipe — more code, same commit path, easy to get wrong on web.

## Risks / Trade-offs

- [Long bios on touch] → Wheel/trackpad still scrolls; touch drag is swipe. Short drags still snap back.
- [Members looking for buttons] → Discovery intro already describes swipe up/down. Liked-users has no intro; keys still work.
