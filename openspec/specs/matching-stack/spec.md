# matching-stack Specification

## Purpose

Captures the member home: a single discovery card with ternary outcomes, a first-use intro, undo, and a liked-users page.

## Requirements

### [PRE] Requirement: Home shell

The system SHALL show an onboarded member a home screen of other people so they can decide whom they know, like, or skip.

#### Scenario: Home chrome
- **WHEN** a member with completed onboarding reaches `/base`
- **THEN** the system SHALL show `StackedCardsScreen` with a settings icon (top left), undo, and liked-users (top right)

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
- **WHEN** the liked-users icon is tapped
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

The system SHALL show one discovery person at a time. Vertical finger-swipe on the card SHALL record know (up) or no interest (down). Left and Right keys SHALL NOT browse this screen.

#### Scenario: One card
- **WHEN** users are available on `/base`
- **THEN** the system SHALL show exactly one card, without previous/next arrows or a 5-card fan

#### Scenario: Controls disabled during dismiss
- **WHEN** a dismiss animation is running
- **THEN** know, not-interested, and light-bulb controls SHALL be disabled

### Requirement: Dismiss and interest

The system SHALL let a member say they know someone, are not interested, or show interest so the queue advances and interest is stored. POST `/swipes/{targetUserId}` SHALL send `{ "outcome": "interest" | "no_interest" | "know" }`.

#### Scenario: I know this person
- **WHEN** the user taps `I know this person`, presses Arrow Up, or swipes the discovery card up
- **THEN** the system SHALL POST `/swipes/{targetUserId}` with `{ "outcome": "know" }`

#### Scenario: Not interested
- **WHEN** the user taps `I’m not interested`, presses Arrow Down, or swipes the discovery card down
- **THEN** the system SHALL POST `/swipes/{targetUserId}` with `{ "outcome": "no_interest" }`

#### Scenario: Light bulb interest
- **WHEN** the user taps the light bulb on the front card
- **THEN** the system SHALL mark the bulb filled yellow (`#F59E0B`), dismiss the card to the right, and POST `/swipes/{targetUserId}` with `{ "outcome": "interest" }`

#### Scenario: Light bulb off state
- **WHEN** the front card has not been marked
- **THEN** the system SHALL show `Icons.lightbulb_outline_rounded` in spark yellow

#### Scenario: Swipe POST failure
- **WHEN** that swipe POST fails
- **THEN** the system SHALL abort the dismiss, unmark the bulb, and leave the card in place

#### Scenario: Replacement card
- **WHEN** swipe succeeds
- **THEN** the system SHALL request a replacement via GET `/swipes/next` excluding remaining and dismissed user ids

#### Scenario: Interested user local immediately
- **WHEN** an interest dismiss succeeds
- **THEN** the system SHALL add that user to the in-memory liked list immediately if not already present, without waiting for GET `/swipes`

#### Scenario: Non-positive user id
- **WHEN** the user id is not positive
- **THEN** the system SHALL skip the swipe POST and treat the dismiss as successful

### Requirement: First-use intro

The system SHALL explain the discovery controls once after onboarding on the first `/base` visit.

#### Scenario: Show intro
- **WHEN** an onboarded member reaches `/base` AND GetStorage key `feedIntroSeen` is not true
- **THEN** the system SHALL show a dialog that tells them people are notified when they show interest, to tap the light bulb to show interest, to swipe down if they are not interested, and to swipe up if they already know them so they will not be shown again

#### Scenario: Got it
- **WHEN** the user taps `Got it`
- **THEN** the system SHALL persist `feedIntroSeen` as true and dismiss the dialog

#### Scenario: Already acted
- **WHEN** the member records a discovery outcome before the intro is dismissed
- **THEN** the system SHALL persist `feedIntroSeen` as true so the dialog does not block them on later visits

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

The system SHALL let a member review people they showed interest in on `/liked-users`.

#### Scenario: Load likes
- **WHEN** `/liked-users` opens
- **THEN** the system SHALL load GET `/swipes` and show up to 5 overlapping cards using the same stack metrics as the former discovery fan (front full size, others scaled to 0.4)

#### Scenario: Empty likes
- **WHEN** there are no liked users
- **THEN** the page SHALL show `No liked users yet.`

#### Scenario: Bulbs on
- **WHEN** a liked card is shown
- **THEN** its light bulb SHALL start filled on

#### Scenario: Unlike
- **WHEN** the user turns the front card’s light bulb off
- **THEN** the system SHALL DELETE `/swipes/{targetUserId}` and drop that person from the page

#### Scenario: Unlike DELETE failure
- **WHEN** that DELETE fails
- **THEN** the system SHALL keep the person in the list and keep the light bulb on

#### Scenario: Browse stack
- **WHEN** the user taps previous/next or presses Arrow Left/Right
- **THEN** the system SHALL bring the previous or next visible stacked card to the front

#### Scenario: List window
- **WHEN** there are more than 5 liked users AND the user taps up/down or presses Arrow Up/Down
- **THEN** the system SHALL shift the window of visible cards through the liked list

#### Scenario: Hide previous/next
- **WHEN** fewer than two stacked cards are visible
- **THEN** the system SHALL NOT show previous/next arrows

#### Scenario: Hide list window arrows
- **WHEN** there are 5 or fewer liked users
- **THEN** the system SHALL NOT show up/down arrows

#### Scenario: Arrow pad diamond
- **WHEN** previous/next and up/down arrows are all shown
- **THEN** the system SHALL lay them out as a diamond (up above, left and right beside, down below), not in a single row

#### Scenario: Arrow pad vertical
- **WHEN** only up/down arrows are shown
- **THEN** the system SHALL stack them vertically

#### Scenario: Arrow pad horizontal
- **WHEN** only previous/next arrows are shown
- **THEN** the system SHALL show them as a horizontal pair

#### Scenario: No know or skip
- **WHEN** `/liked-users` is shown
- **THEN** the system SHALL NOT show I know this person or I’m not interested buttons
