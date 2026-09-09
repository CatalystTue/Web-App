## Purpose

[PRE] Captures the existing member home: a stack of other users' cards, like/dismiss actions, liked-users drawer, and undo.

## ADDED Requirements

### Requirement: Home shell
[PRE] The system SHALL show an onboarded member a home screen of other people so they can decide whom they know, like, or skip.

#### Scenario: Home chrome
- **WHEN** a member with completed onboarding reaches `/base`
- **THEN** [PRE] the system SHALL show `StackedCardsScreen` with a settings icon (top left), undo, and liked-users (top right)

#### Scenario: Load stack
- **WHEN** `/base` opens
- **THEN** [PRE] the system SHALL load a preview stack via repeated GET `/swipes/next` (default target size 5) and GET `/swipes` for liked users

#### Scenario: Loading indicator
- **WHEN** stack users are loading
- **THEN** [PRE] the system SHALL show a centered progress indicator

#### Scenario: Empty stack
- **WHEN** the stack has no cards
- **THEN** [PRE] the system SHALL show `No more users in queue. Check again later.`

#### Scenario: Settings
- **WHEN** settings is tapped
- **THEN** [PRE] the system SHALL navigate to `/settings`

### Requirement: Card content
[PRE] The system SHALL show each card with another user's profile fields so the member can decide how to act.

#### Scenario: Visible fields
- **WHEN** a card is rendered
- **THEN** [PRE] it SHALL show name, affiliation, position, optional location, and a scrollable description

#### Scenario: Empty name fallback
- **WHEN** name is empty
- **THEN** [PRE] the card SHALL fall back to `Card {n}`

#### Scenario: Empty affiliation
- **WHEN** affiliation is empty
- **THEN** [PRE] the card SHALL show `No affiliation`

#### Scenario: Empty position
- **WHEN** position is empty
- **THEN** [PRE] the card SHALL show `No position`

#### Scenario: Empty description
- **WHEN** description is empty
- **THEN** [PRE] the card SHALL show `No description`

#### Scenario: API field mapping
- **WHEN** a card is parsed from the API
- **THEN** [PRE] the system SHALL map `id`, `name` (or `username` / `title`), `description`, `affiliation`, `position`, and `location`

### Requirement: Browse the stack
[PRE] The system SHALL let a member move between visible cards so they can inspect more than the front card.

#### Scenario: Overlapping cards
- **WHEN** users are available
- **THEN** [PRE] the system SHALL show up to 5 overlapping cards, with the front card full size and others scaled to 0.4

#### Scenario: Previous next
- **WHEN** the user taps previous/next or presses Arrow Left/Right
- **THEN** [PRE] the system SHALL bring the previous or next stacked card to the front

#### Scenario: Controls disabled during dismiss
- **WHEN** a dismiss animation is running
- **THEN** [PRE] browse and dismiss controls SHALL be disabled

### Requirement: Dismiss and like
[PRE] The system SHALL let a member say they know someone, are not interested, or like them so the queue advances and likes are stored.

#### Scenario: Dismiss up
- **WHEN** the user dismisses up (button or Arrow Up, tooltip `I know this person`)
- **THEN** [PRE] the system SHALL POST `/swipes/{targetUserId}` with `{ "interested": false }`

#### Scenario: Dismiss down
- **WHEN** the user dismisses down (button or Arrow Down, tooltip `Not interested`)
- **THEN** [PRE] the system SHALL POST `/swipes/{targetUserId}` with `{ "interested": false }`

#### Scenario: Heart like
- **WHEN** the user hearts the front card
- **THEN** [PRE] the system SHALL mark the card, dismiss it to the right, and POST `/swipes/{targetUserId}` with `{ "interested": true }`

#### Scenario: Swipe POST failure
- **WHEN** that swipe POST fails
- **THEN** [PRE] the system SHALL abort the dismiss, unmark the heart, and leave the card in the stack

#### Scenario: Replacement card
- **WHEN** swipe succeeds
- **THEN** [PRE] the system SHALL request a replacement via GET `/swipes/next` excluding remaining and dismissed user ids

#### Scenario: Hearted user local immediately
- **WHEN** a hearted dismiss succeeds
- **THEN** [PRE] the system SHALL add that user to the in-memory liked list immediately if not already present, without waiting for GET `/swipes`

#### Scenario: Non-positive user id
- **WHEN** the user id is not positive
- **THEN** [PRE] the system SHALL skip the swipe POST and treat the dismiss as successful

### Requirement: Undo
[PRE] The system SHALL let a member undo the last dismiss so they can recover a card they acted on by mistake.

#### Scenario: Restore snapshot
- **WHEN** undo is available AND the user taps Undo
- **THEN** [PRE] the system SHALL restore the previous stack snapshot

#### Scenario: Undo liked user
- **WHEN** the undone dismiss had saved a liked user
- **THEN** [PRE] the system SHALL remove that user from the in-memory liked list

#### Scenario: Undo swipe delete
- **WHEN** the undone user id is positive
- **THEN** [PRE] the system SHALL DELETE `/swipes/{targetUserId}`

#### Scenario: Undo no-op
- **WHEN** no undo history exists or a dismiss is in progress
- **THEN** [PRE] undo SHALL do nothing

### Requirement: Liked users drawer
[PRE] The system SHALL let a member see people they liked so they can review them later.

#### Scenario: Open drawer
- **WHEN** the liked-users icon is tapped
- **THEN** [PRE] the system SHALL refresh GET `/swipes` and open a right-side dialog titled `Liked Users`

#### Scenario: Empty likes
- **WHEN** there are no liked users
- **THEN** [PRE] the dialog SHALL show `No liked users yet.`

#### Scenario: Liked rows
- **WHEN** liked users exist
- **THEN** [PRE] each row SHALL show name and a subtitle of affiliation, position, location, and description (non-empty lines only)

#### Scenario: Close drawer
- **WHEN** the user taps Close or the barrier
- **THEN** [PRE] the dialog SHALL dismiss
