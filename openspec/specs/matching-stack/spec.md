# matching-stack Specification

## Purpose

Captures the member home: a single discovery card with ternary outcomes, a first-use intro, undo, and a liked-users page.

## Requirements

### [PRE] Requirement: Home shell

The system SHALL show an onboarded member a home screen of other people so they can decide whom they know, like, or skip.

#### Scenario: Home chrome
- **WHEN** a member with completed onboarding reaches `/base`
- **THEN** the system SHALL show `StackedCardsScreen` with a settings icon (top left), undo, and an outline light bulb (top right)

#### Scenario: Load stack
- **WHEN** `/base` opens
- **THEN** the system SHALL load one discovery card via GET `/swipes/next` (target size 1) and MAY load GET `/swipes` for liked users in the background

#### Scenario: Loading indicator
- **WHEN** stack users are loading
- **THEN** the system SHALL show a centered progress indicator

#### Scenario: Empty stack
- **WHEN** the stack has no cards
- **THEN** the system SHALL show `No more users in queue. Check again later.`

#### Scenario: Settings
- **WHEN** settings is tapped
- **THEN** the system SHALL navigate to `/settings`

#### Scenario: Liked chrome opens page
- **WHEN** the home outline light bulb is tapped
- **THEN** the system SHALL navigate to `/liked-users`

### [PRE] Requirement: Card content

The system SHALL show each card with another user's profile fields so the member can decide how to act.

#### Scenario: Visible fields
- **WHEN** a card is rendered
- **THEN** it SHALL show name, affiliation, position, optional location, and a scrollable description

#### Scenario: Empty name fallback
- **WHEN** name is empty
- **THEN** the card SHALL fall back to `Card {n}`

#### Scenario: Empty affiliation
- **WHEN** affiliation is empty
- **THEN** the card SHALL show `No affiliation`

#### Scenario: Empty position
- **WHEN** position is empty
- **THEN** the card SHALL show `No position`

#### Scenario: Empty description
- **WHEN** description is empty
- **THEN** the card SHALL show `No description`

#### Scenario: API field mapping
- **WHEN** a card is parsed from the API
- **THEN** the system SHALL map `id`, `name` (or `username` / `title`), `description`, `affiliation`, `position`, and `location`

### Requirement: Single discovery card

The system SHALL show one discovery person at a time on `/base`. The system SHALL show labeled outcome buttons for I know them, Interesting!, and Not interested. The system SHALL NOT show skip or back controls. The system SHALL NOT show a diamond arrow pad.

#### Scenario: One card
- **WHEN** users are available on `/base`
- **THEN** the system SHALL show exactly one card, without a 5-card fan

#### Scenario: No labeled know or skip
- **WHEN** `/base` discovery is shown
- **THEN** the system SHALL NOT show `I know this person` or `I’m not interested` buttons

#### Scenario: Arrow pad
- **WHEN** a discovery card is shown
- **THEN** the system SHALL NOT show a diamond pad with Back, Skip, or up/down nested between them

#### Scenario: Bio drag still swipes
- **WHEN** the pointer starts on the card description
- **THEN** a vertical swipe past the commit threshold SHALL still record know or no interest

#### Scenario: Controls disabled during dismiss
- **WHEN** a dismiss animation is running
- **THEN** swipe, outcome buttons, Arrow keys, and chrome light-bulb controls SHALL be disabled

#### Scenario: Labeled outcome buttons
- **WHEN** `/base` discovery is shown
- **THEN** the system SHALL show `I know them` immediately above the card, `Interesting!` immediately below the card, and `Not interested` immediately below Interesting!, each the same width as the card, in the same format as `/liked-users`

#### Scenario: No skip or back
- **WHEN** `/base` discovery is shown
- **THEN** the system SHALL NOT show Skip or Back

#### Scenario: Horizontal drag ignored
- **WHEN** the pointer moves left or right on the home discovery card
- **THEN** the system SHALL NOT offset the card horizontally and SHALL NOT skip or go back

### Requirement: Dismiss and interest

The system SHALL let a member say they know someone, show interest, or say they are not interested. The system SHALL NOT skip or go back on `/base`. POST `/swipes/{targetUserId}` SHALL send `{ "outcome": "interest" | "no_interest" | "know" }` only for those three outcomes.

#### Scenario: Skip
- **WHEN** the user swipes the discovery card right, taps Skip, or presses Arrow Right
- **THEN** the system SHALL keep the current person on screen and SHALL NOT POST a swipe

#### Scenario: Back
- **WHEN** the user swipes left, taps Back, or presses Arrow Left
- **THEN** the system SHALL keep the current person on screen and SHALL NOT POST

#### Scenario: Back unavailable
- **WHEN** the user swipes left or presses Arrow Left on `/base`
- **THEN** the system SHALL keep the current person on screen

#### Scenario: I know this person
- **WHEN** the user swipes the discovery card up, taps `I know them`, or presses Arrow Up
- **THEN** the system SHALL POST `/swipes/{targetUserId}` with `{ "outcome": "know" }`

#### Scenario: Not interested
- **WHEN** the user swipes the discovery card down, taps `Not interested`, or presses Arrow Down
- **THEN** the system SHALL POST `/swipes/{targetUserId}` with `{ "outcome": "no_interest" }`

#### Scenario: Light bulb interest
- **WHEN** the user taps `Interesting!`
- **THEN** the system SHALL mark the Interesting! bulb filled yellow (`#F59E0B`), dismiss the card to the right, and POST `/swipes/{targetUserId}` with `{ "outcome": "interest" }`

#### Scenario: Light bulb off state
- **WHEN** the front card has not been marked interesting
- **THEN** the system SHALL show `Icons.lightbulb_outline_rounded` in spark yellow on the Interesting! button

#### Scenario: Swipe POST failure
- **WHEN** that swipe POST fails
- **THEN** the system SHALL abort the dismiss, unmark the Interesting! bulb, and leave the card in place

#### Scenario: Replacement card
- **WHEN** a recorded swipe succeeds
- **THEN** the system SHALL request a replacement via GET `/swipes/next` excluding remaining and dismissed user ids

#### Scenario: Interested user local immediately
- **WHEN** an interest dismiss succeeds
- **THEN** the system SHALL add that user to the in-memory liked list immediately if not already present, without waiting for GET `/swipes`

#### Scenario: Non-positive user id
- **WHEN** the user id is not positive
- **THEN** the system SHALL skip the swipe POST and treat the dismiss as successful

#### Scenario: No keyboard shortcut for interest
- **WHEN** the user presses Arrow Left or Arrow Right on `/base`
- **THEN** the system SHALL NOT move or dismiss the card and SHALL NOT show interest

### Requirement: First-use intro

The system SHALL explain the discovery controls once after onboarding on the first `/base` visit. The system SHALL NOT show a separate intro on `/liked-users`.

#### Scenario: Show intro
- **WHEN** an onboarded member reaches `/base` AND GetStorage key `feedIntroSeen` is not true
- **THEN** the system SHALL show a dialog titled `How this works` whose body is exactly:

```
We notify people when you show interest.

Tap Interesting! to show interest.

Swipe down or tap Not interested if you’re not interested.

Swipe up or tap I know them if you already know them. We won’t show them again.

The light bulb at the top right opens the liked people page, where you can review people you’ve marked interesting.

Tap Undo at the top right if you act by mistake.
```

#### Scenario: Got it
- **WHEN** the user taps `Got it`
- **THEN** the system SHALL persist `feedIntroSeen` as true and dismiss the dialog

#### Scenario: Already acted
- **WHEN** the member records a discovery outcome before the intro is dismissed
- **THEN** the system SHALL persist `feedIntroSeen` as true so the dialog does not block them on later visits

#### Scenario: No likes intro
- **WHEN** `/liked-users` is shown
- **THEN** the system SHALL NOT show a `How this works` dialog

#### Scenario: Restore snapshot
- **WHEN** undo is available AND the user taps Undo
- **THEN** the system SHALL restore the previous stack snapshot

#### Scenario: Undo liked user
- **WHEN** the undone dismiss had saved a liked user
- **THEN** the system SHALL remove that user from the in-memory liked list

#### Scenario: Undo swipe delete
- **WHEN** the undone user id is positive
- **THEN** the system SHALL DELETE `/swipes/{targetUserId}`

#### Scenario: Undo no-op
- **WHEN** no undo history exists or a dismiss is in progress
- **THEN** undo SHALL do nothing

### [PRE] Requirement: Undo

The system SHALL let a member undo the last dismiss so they can recover a card they acted on by mistake.

#### Scenario: Restore snapshot
- **WHEN** undo is available AND the user taps Undo
- **THEN** the system SHALL restore the previous stack snapshot

#### Scenario: Undo liked user
- **WHEN** the undone dismiss had saved a liked user
- **THEN** the system SHALL remove that user from the in-memory liked list

#### Scenario: Undo swipe delete
- **WHEN** the undone user id is positive
- **THEN** the system SHALL DELETE `/swipes/{targetUserId}`

#### Scenario: Undo no-op
- **WHEN** no undo history exists or a dismiss is in progress
- **THEN** undo SHALL do nothing

### Requirement: Liked users page

The system SHALL let a member review people they showed interest in on `/liked-users`. The view SHALL show a center card with previous/next peeks when neighbors exist. The system SHALL show labeled `I know them` and `Not interested` buttons. The system SHALL NOT show Interesting, a card light bulb, unlike, or DELETE from this page. Swipe up or down SHALL edit that swipe to know or no interest. Browse SHALL use horizontal swipe, Arrow Left/Right, and side chevrons when those chevrons are on screen. Chevrons SHALL stay in the card-row layout and dim when that direction is unavailable; on a narrow viewport they MAY be cropped at the screen edge while neighbor peeks still show beside the center card. Browse SHALL loop only when three or more liked users exist. The likes-bulb switch SHALL start on (filled); turning it off SHALL return to `/base` even when the route cannot pop. The view SHALL NOT show a `Liked Users` title.

#### Scenario: Load likes
- **WHEN** `/liked-users` opens
- **THEN** the system SHALL load GET `/swipes` and show a center card when at least one liked user exists

#### Scenario: Empty likes
- **WHEN** there are no liked users
- **THEN** the page SHALL show `No liked users yet.`

#### Scenario: No title
- **WHEN** `/liked-users` is shown
- **THEN** the system SHALL NOT show the text `Liked Users`

#### Scenario: Liked chrome
- **WHEN** `/liked-users` is shown
- **THEN** the system SHALL show settings (top left) in the primary color and the same undo + likes-bulb switch as `/base`, with the bulb on (filled spark yellow) and tooltip `Liked people`

#### Scenario: Liked chrome off
- **WHEN** the likes-bulb switch is turned off
- **THEN** the system SHALL pop `/liked-users` when that route can pop

#### Scenario: Liked chrome off when stack cannot pop
- **WHEN** `/liked-users` is shown AND the route cannot pop AND the likes-bulb switch is turned off
- **THEN** the system SHALL navigate to `/base`

#### Scenario: Bulbs on
- **WHEN** a liked card is shown
- **THEN** the system SHALL NOT show a light bulb on the card

#### Scenario: Unlike
- **WHEN** a liked card is shown
- **THEN** the system SHALL NOT offer unlike or DELETE from the card

#### Scenario: Unlike DELETE failure
- **WHEN** `/liked-users` is shown
- **THEN** the system SHALL NOT DELETE `/swipes/{targetUserId}` because a card bulb was turned off

#### Scenario: Skip and back
- **WHEN** two or more liked users exist AND the user taps an on-screen enabled side chevron, swipes right or left in an available direction, or presses Arrow Right/Left
- **THEN** the system SHALL show the next or previous person in the liked list when that direction is available, without POSTing

#### Scenario: Browse does not wrap
- **WHEN** exactly two liked users exist AND the user browses past the last person or back past the first
- **THEN** the system SHALL keep that person on screen

#### Scenario: One person no browse
- **WHEN** exactly one liked user exists
- **THEN** both chevrons SHALL be dimmed if they are on screen, left/right swipe and Arrow Left/Right SHALL leave that person on screen, and the system SHALL NOT show peeks

#### Scenario: I know this person
- **WHEN** the user taps `I know them`, swipes the card up, or presses Arrow Up
- **THEN** the system SHALL POST `/swipes/{targetUserId}` with `{ "outcome": "know" }` and drop that person from the page

#### Scenario: Not interested
- **WHEN** the user taps `Not interested`, swipes the card down, or presses Arrow Down
- **THEN** the system SHALL POST `/swipes/{targetUserId}` with `{ "outcome": "no_interest" }` and drop that person from the page

#### Scenario: Edit POST failure
- **WHEN** that know or no-interest POST fails
- **THEN** the system SHALL abort the dismiss and leave the person on screen

#### Scenario: Bio drag still swipes
- **WHEN** the pointer starts on the card description
- **THEN** a swipe past the commit threshold SHALL still browse horizontally when that direction is available, or edit the swipe vertically

#### Scenario: Arrow pad
- **WHEN** a liked card is shown
- **THEN** the system SHALL keep `arrow_back_ios_new` and `arrow_forward_ios` in the card row (no Skip or Back tooltips) and SHALL NOT show the discovery diamond pad

#### Scenario: Both chevrons stay visible
- **WHEN** a liked card is shown on a viewport wide enough for peeks and chevrons
- **THEN** both side chevrons SHALL be visible and hittable; neighbor peeks SHALL NOT cover them

#### Scenario: Narrow viewport crops peeks
- **WHEN** `/liked-users` is shown on a typical phone-width viewport
- **THEN** the center card and action buttons SHALL stay near the preferred 312×480 size, neighbor peeks SHALL still paint in the leftover width beside the center card, and only overflow past the viewport edges (chevrons and outer peek) SHALL be clipped

#### Scenario: No know or skip buttons
- **WHEN** `/liked-users` is shown
- **THEN** the system SHALL NOT show `I know this person` or `I’m not interested` buttons

#### Scenario: Two people do not loop
- **WHEN** exactly two liked users exist
- **THEN** the system SHALL open on the first person, dim the left chevron, enable the right chevron, and show a peek of the second person behind on the right (peek and chevron MAY be cropped on a narrow viewport)

#### Scenario: Two people after going right
- **WHEN** exactly two liked users exist AND the member has browsed to the second person
- **THEN** the system SHALL dim the right chevron, enable the left chevron, show a peek of the first person behind on the left, and return to the first person when the member browses left

#### Scenario: Three or more loop
- **WHEN** three or more liked users exist
- **THEN** the system SHALL loop browse, show a left peek of the previous person and a right peek of the next person (modulo), and enable both chevrons except during dismiss

#### Scenario: Unused browse direction
- **WHEN** a chevron is dimmed AND the user swipes or presses Arrow in that direction
- **THEN** the system SHALL NOT drag-follow, wrap, or change the focused person

#### Scenario: Labeled liked buttons
- **WHEN** a liked card is shown
- **THEN** the system SHALL show `I know them` immediately above the card row and `Not interested` immediately below it, each the same width as the center card, not at the screen edges

#### Scenario: Undo dimmed when empty
- **WHEN** `/liked-users` is shown AND there is nothing to undo
- **THEN** the system SHALL show Undo dimmed and disabled

### Requirement: Liked users undo

The system SHALL let a member undo the last removal on `/liked-users` (unlike, know, or no interest) so they can restore a person they removed by mistake. Restore SHALL use POST `/swipes/{targetUserId}` with `{ "outcome": "interest" }`.

#### Scenario: Undo chrome
- **WHEN** `/liked-users` is shown
- **THEN** the system SHALL show an Undo control with tooltip `Undo`

#### Scenario: Restore removal
- **WHEN** undo is available AND the user taps Undo
- **THEN** the system SHALL restore the last removed person to the page, including when the page was showing `No liked users yet.`

#### Scenario: Undo swipe create
- **WHEN** the restored user id is positive
- **THEN** the system SHALL POST `/swipes/{targetUserId}` with `{ "outcome": "interest" }`

#### Scenario: Undo POST failure
- **WHEN** that POST fails
- **THEN** the system SHALL keep the person off the page

#### Scenario: Non-positive user id
- **WHEN** the restored user id is not positive
- **THEN** the system SHALL skip the swipe POST and treat the restore as successful

#### Scenario: Undo no-op
- **WHEN** no removal history exists or a removal is in progress
- **THEN** undo SHALL do nothing

### Requirement: Feedback prompt after swipes

The system SHALL invite a member to the public feedback form once they have used discovery enough times. The prompt SHALL use the same dialog style as the first-use intro on `/base`. The system SHALL NOT show this prompt on `/liked-users`. The system SHALL NOT show it while the first-use intro is showing.

A counted swipe is a discovery skip, interest, know, or not-interested action on `/base`. Back and undo SHALL NOT increment the count. The count SHALL persist in local cache so later `/base` visits (including after login) can show the prompt if the threshold is already met.

#### Scenario: Count discovery swipes
- **WHEN** the member skips, shows interest, marks know, or marks not interested on `/base`
- **THEN** the system SHALL increment the persisted discovery swipe count by one

#### Scenario: Back and undo do not count
- **WHEN** the member goes back or undoes a dismiss on `/base`
- **THEN** the system SHALL NOT increment the discovery swipe count

#### Scenario: Show prompt after threshold
- **WHEN** an onboarded member is on `/base` AND the first-use intro is not showing AND the persisted swipe count is at least the feedback swipe threshold AND GetStorage key `feedbackPromptSeen` is not true
- **THEN** the system SHALL show a dialog that asks for feedback and offers a control that opens the configured feedback form URL in a new tab

#### Scenario: Show after login when already over threshold
- **WHEN** the member reaches `/base` after login AND the persisted swipe count is already at least the threshold AND `feedbackPromptSeen` is not true AND the first-use intro is not showing
- **THEN** the system SHALL show the feedback dialog

#### Scenario: Dismiss prompt
- **WHEN** the user dismisses the feedback dialog
- **THEN** the system SHALL persist `feedbackPromptSeen` as true and SHALL NOT show the dialog again

#### Scenario: Open form from prompt
- **WHEN** the user opens the feedback form from the dialog
- **THEN** the system SHALL open the configured feedback form URL in a new tab and persist `feedbackPromptSeen` as true

#### Scenario: Disabled when threshold is not positive
- **WHEN** the feedback swipe threshold is less than 1
- **THEN** the system SHALL NOT show the feedback dialog

#### Scenario: No likes feedback prompt
- **WHEN** `/liked-users` is shown
- **THEN** the system SHALL NOT show the feedback dialog

### Requirement: Discovery card appearance

The system SHALL size discovery and liked cards from the previous Liked people 260×400 (13:20) scaled in steps to 312×480, with extra vertical margin around the cluster. Affiliation, position, and location SHALL wrap up to 3 lines and then ellipsis. Name SHALL wrap up to 2 lines. Description SHALL stay scrollable. Stripe and border SHALL share one color from a five-color muted cycle so the next person is obviously a different card. `/base` and `/liked-users` SHALL share one layout frame so the extra Home action does not move the card.

#### Scenario: Responsive card size
- **WHEN** a discovery or liked card is shown on a typical desktop viewport
- **THEN** the system SHALL use about 312×480 for the card (13:20), leave extra margin above and below the action cluster, and SHALL NOT grow the card toward 480×600

#### Scenario: Short viewport shrinks the card
- **WHEN** a discovery or liked card is shown on a short viewport
- **THEN** the system SHALL shrink the card before clipping the action buttons

#### Scenario: Shared vertical frame
- **WHEN** `/base` and `/liked-users` are shown at the same viewport size
- **THEN** the card top SHALL sit at the same vertical position; Home’s extra Interesting! button SHALL NOT shift the card

#### Scenario: Long affiliation wraps
- **WHEN** affiliation, position, or location is longer than one line
- **THEN** the system SHALL wrap that field up to 3 lines and then ellipsis

#### Scenario: Muted color cycle
- **WHEN** successive cards are shown
- **THEN** stripe and border SHALL both use the same color from `#4F5D75`, `#4F6D75`, `#4F756C`, `#5A7554`, `#645575` in cycle, and SHALL NOT use red, pink, or amber/gold card colors

### Requirement: Interesting! button chrome

The Interesting! control on `/base` SHALL read as a card-like action: white fill, grey divider border, header-color label, and a spark-yellow bulb on the right. I know them and Not interested SHALL use filled lighter-slate (`#647086`) and reject-red (`#CE6E6E`) actions with the plan’s icons. Every labeled outcome button SHALL place its icon on the right of the button and SHALL center the label horizontally and vertically so the icon does not pull the text. The icon SHALL share the label’s vertical midpoint. Overlay layout SHALL NOT grow the button past the compact ~54px chrome height. Action labels SHALL be slightly larger than body button text (~16px). Action icons SHALL be larger than the default 24px icon (~28px). Home SHALL use a 5px gap after Interesting! before Not interested.

#### Scenario: Interesting! appearance
- **WHEN** `/base` shows Interesting!
- **THEN** the button SHALL use a white fill, a `Colors.grey[300]` border, a header-color `Interesting!` label, and a spark-yellow light bulb on the right

#### Scenario: I know them appearance
- **WHEN** `/base` or `/liked-users` shows I know them
- **THEN** the button SHALL use a filled lighter slate `#647086` (not global `primaryColor`), a white `I know them` label, and `Icons.expand_less` on the right

#### Scenario: Not interested appearance
- **WHEN** `/base` or `/liked-users` shows Not interested
- **THEN** the button SHALL use a filled reject red `#CE6E6E` (less candy than `#E2180E`, not dim `#7A5458`, a little lighter than `#C75A5A`), a white `Not interested` label, and `Icons.expand_more` on the right

#### Scenario: Outcome icons on the right
- **WHEN** `/base` or `/liked-users` shows a labeled outcome button
- **THEN** that button’s icon SHALL sit on the right of the button and the label SHALL be centered horizontally and vertically in the button, sharing a vertical midpoint with the icon

#### Scenario: Compact outcome buttons
- **WHEN** `/base` or `/liked-users` shows a labeled outcome button
- **THEN** the button height SHALL stay the compact chrome size (~54px) and SHALL NOT grow from the overlay alignment layout

#### Scenario: Space after Interesting!
- **WHEN** `/base` discovery is shown
- **THEN** the gap below Interesting! SHALL be 5px, and the card-adjacent gaps SHALL be 10px (I know them→card and card→first below-card button)

### Requirement: Liked users carousel motion

When browse is available on `/liked-users`, neighbor cards SHALL sit behind the center card, smaller, with overlap. A skip/back transition SHALL slide the current card toward the opposite side while the incoming peek grows into center.

#### Scenario: Peek scale and overlap
- **WHEN** a neighbor peek is shown
- **THEN** it SHALL sit behind the center card at about 0.72 scale with overlap of about 35% of card width

#### Scenario: Browse animation
- **WHEN** the member browses to a neighbor
- **THEN** the current card SHALL slide toward the opposite side and scale down while the incoming peek grows into center

#### Scenario: Peeks are not the action target
- **WHEN** a peek is shown
- **THEN** pointer events on that peek SHALL NOT act on the peek’s person; a tap MAY browse in that direction

### Requirement: Discovery chrome polish

Settings and Undo on `/base` and `/liked-users` SHALL use the primary color. Undo SHALL be dimmed and disabled when there is nothing to undo. `/base` and `/liked-users` SHALL share one likes-bulb + undo switch. The likes bulb SHALL sit above Undo. The likes bulb SHALL be spark yellow with tooltip `Liked people` (outline off on home, filled on on liked).

#### Scenario: Home chrome colors
- **WHEN** `/base` is shown
- **THEN** the system SHALL show settings and undo in the primary color, an outline spark-yellow likes bulb with tooltip `Liked people`, and Undo dimmed when there is nothing to undo

#### Scenario: Shared likes switch
- **WHEN** `/base` or `/liked-users` is shown
- **THEN** undo and the likes bulb SHALL be the same shared control, with the bulb above Undo, off on `/base` and on on `/liked-users`

#### Scenario: Actions hug the card
- **WHEN** `/base` or `/liked-users` is shown on a tall viewport
- **THEN** the labeled outcome buttons SHALL sit immediately against the card, not at the screen edges
