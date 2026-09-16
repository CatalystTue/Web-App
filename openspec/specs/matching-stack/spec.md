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

The system SHALL show one discovery person at a time. The screen SHALL NOT show labeled know or not-interested buttons. A diamond arrow pad SHALL sit under the card with hover tooltips.

#### Scenario: One card
- **WHEN** users are available on `/base`
- **THEN** the system SHALL show exactly one card, without a 5-card fan

#### Scenario: No labeled know or skip
- **WHEN** `/base` discovery is shown
- **THEN** the system SHALL NOT show `I know this person` or `I’m not interested` buttons

#### Scenario: Arrow pad
- **WHEN** a discovery card is shown
- **THEN** the system SHALL show a pad with Back on the left, Skip on the right, and up/down nested between them, with tooltips `Back`, `Skip`, `I know this person`, and `I'm not interested`

#### Scenario: Bio drag still swipes
- **WHEN** the pointer starts on the card description
- **THEN** a swipe past the commit threshold SHALL still skip, go back, or record know / no interest

#### Scenario: Controls disabled during dismiss
- **WHEN** a dismiss animation is running
- **THEN** swipe, arrow pad, Arrow keys, and light-bulb controls SHALL be disabled

### Requirement: Dismiss and interest

The system SHALL let a member skip, go back, say they know someone, say they are not interested, or show interest. Skip SHALL NOT POST. POST `/swipes/{targetUserId}` SHALL send `{ "outcome": "interest" | "no_interest" | "know" }` only for like, not interested, and know.

#### Scenario: Skip
- **WHEN** the user swipes the discovery card right, taps Skip, or presses Arrow Right
- **THEN** the system SHALL show the next person in the local queue, or fetch GET `/swipes/next` excluding queued and dismissed ids, without POSTing a swipe

#### Scenario: Back
- **WHEN** a skipped person is in the local queue AND the user swipes left, taps Back, or presses Arrow Left
- **THEN** the system SHALL show that previous person again without POSTing

#### Scenario: Back unavailable
- **WHEN** there is no previous person in the local queue AND the user swipes left or presses Arrow Left
- **THEN** the system SHALL keep the current person on screen

#### Scenario: I know this person
- **WHEN** the user swipes the discovery card up, taps the up arrow, or presses Arrow Up
- **THEN** the system SHALL POST `/swipes/{targetUserId}` with `{ "outcome": "know" }`

#### Scenario: Not interested
- **WHEN** the user swipes the discovery card down, taps the down arrow, or presses Arrow Down
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
- **WHEN** a recorded swipe succeeds
- **THEN** the system SHALL request a replacement via GET `/swipes/next` excluding remaining and dismissed user ids

#### Scenario: Interested user local immediately
- **WHEN** an interest dismiss succeeds
- **THEN** the system SHALL add that user to the in-memory liked list immediately if not already present, without waiting for GET `/swipes`

#### Scenario: Non-positive user id
- **WHEN** the user id is not positive
- **THEN** the system SHALL skip the swipe POST and treat the dismiss as successful

### Requirement: First-use intro

The system SHALL explain the discovery controls once after onboarding on the first `/base` visit. The system SHALL NOT show a separate intro on `/liked-users`.

#### Scenario: Show intro
- **WHEN** an onboarded member reaches `/base` AND GetStorage key `feedIntroSeen` is not true
- **THEN** the system SHALL show a dialog that tells them people are notified when they show interest, to tap the light bulb to show interest, to swipe right to skip and left to go back, to swipe down if they are not interested, and to swipe up if they already know them so they will not be shown again

#### Scenario: Got it
- **WHEN** the user taps `Got it`
- **THEN** the system SHALL persist `feedIntroSeen` as true and dismiss the dialog

#### Scenario: Already acted
- **WHEN** the member records a discovery outcome before the intro is dismissed
- **THEN** the system SHALL persist `feedIntroSeen` as true so the dialog does not block them on later visits

#### Scenario: No likes intro
- **WHEN** `/liked-users` is shown
- **THEN** the system SHALL NOT show a `How this works` dialog

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

The system SHALL let a member review people they showed interest in on `/liked-users`. The view SHALL show one person at a time and SHALL use the same skip / back / know / not-interested pad as discovery. Swipe up or down SHALL edit that swipe. Skip and back SHALL NOT wrap. The chrome light bulb SHALL start filled; tapping it off SHALL return to `/base`. The view SHALL NOT show a `Liked Users` title.

#### Scenario: Load likes
- **WHEN** `/liked-users` opens
- **THEN** the system SHALL load GET `/swipes` and show exactly one card when at least one liked user exists

#### Scenario: Empty likes
- **WHEN** there are no liked users
- **THEN** the page SHALL show `No liked users yet.`

#### Scenario: No title
- **WHEN** `/liked-users` is shown
- **THEN** the system SHALL NOT show the text `Liked Users`

#### Scenario: Liked chrome
- **WHEN** `/liked-users` is shown
- **THEN** the system SHALL show settings (top left), undo, and a filled light bulb (top right)

#### Scenario: Liked chrome off
- **WHEN** the filled chrome light bulb is tapped
- **THEN** the system SHALL pop `/liked-users`

#### Scenario: Bulbs on
- **WHEN** a liked card is shown
- **THEN** its light bulb SHALL start filled on

#### Scenario: Unlike
- **WHEN** the user turns the card’s light bulb off
- **THEN** the system SHALL DELETE `/swipes/{targetUserId}` and drop that person from the page

#### Scenario: Unlike DELETE failure
- **WHEN** that DELETE fails
- **THEN** the system SHALL keep the person in the list and keep the light bulb on

#### Scenario: Skip and back
- **WHEN** two or more liked users exist AND the user taps Skip or Back, swipes right or left, or presses Arrow Right/Left
- **THEN** the system SHALL show the next or previous person in the liked list when that direction is available

#### Scenario: Browse does not wrap
- **WHEN** the user skips on the last person or goes back on the first
- **THEN** the system SHALL keep that person on screen

#### Scenario: One person no browse
- **WHEN** exactly one liked user exists
- **THEN** skip and back SHALL leave that person on screen

#### Scenario: I know this person
- **WHEN** the user taps the up arrow, swipes the card up, or presses Arrow Up
- **THEN** the system SHALL POST `/swipes/{targetUserId}` with `{ "outcome": "know" }` and drop that person from the page

#### Scenario: Not interested
- **WHEN** the user taps the down arrow, swipes the card down, or presses Arrow Down
- **THEN** the system SHALL POST `/swipes/{targetUserId}` with `{ "outcome": "no_interest" }` and drop that person from the page

#### Scenario: Edit POST failure
- **WHEN** that know or no-interest POST fails
- **THEN** the system SHALL abort the dismiss and leave the person on screen

#### Scenario: Bio drag still swipes
- **WHEN** the pointer starts on the card description
- **THEN** a swipe past the commit threshold SHALL still skip, go back, or edit the swipe

#### Scenario: Arrow pad
- **WHEN** a liked card is shown
- **THEN** the system SHALL show the same pad and tooltips as discovery (`Back`, `Skip`, `I know this person`, `I'm not interested`)

#### Scenario: No know or skip buttons
- **WHEN** `/liked-users` is shown
- **THEN** the system SHALL NOT show I know this person or I’m not interested buttons

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
