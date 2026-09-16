## MODIFIED Requirements

### Requirement: Single discovery card

The system SHALL show one discovery person at a time. Vertical finger-swipe on the card SHALL record know (up) or no interest (down). The discovery screen SHALL NOT show labeled know or not-interested buttons. Left and Right keys SHALL NOT browse this screen.

#### Scenario: One card
- **WHEN** users are available on `/base`
- **THEN** the system SHALL show exactly one card, without previous/next arrows or a 5-card fan

#### Scenario: No labeled know or skip
- **WHEN** `/base` discovery is shown
- **THEN** the system SHALL NOT show `I know this person` or `I’m not interested` buttons

#### Scenario: Bio drag still swipes
- **WHEN** the pointer starts on the card description
- **THEN** a vertical swipe past the commit threshold SHALL still record know or no interest

#### Scenario: Controls disabled during dismiss
- **WHEN** a dismiss animation is running
- **THEN** vertical swipe, Arrow Up, Arrow Down, and light-bulb controls SHALL be disabled

### Requirement: Dismiss and interest

The system SHALL let a member say they know someone, are not interested, or show interest so the queue advances and interest is stored. POST `/swipes/{targetUserId}` SHALL send `{ "outcome": "interest" | "no_interest" | "know" }`.

#### Scenario: I know this person
- **WHEN** the user swipes the discovery card up or presses Arrow Up
- **THEN** the system SHALL POST `/swipes/{targetUserId}` with `{ "outcome": "know" }`

#### Scenario: Not interested
- **WHEN** the user swipes the discovery card down or presses Arrow Down
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
- **WHEN** the user swipes the front card left or right, or presses Arrow Left/Right
- **THEN** the system SHALL bring the previous or next visible stacked card to the front

#### Scenario: List window
- **WHEN** there are more than 5 liked users AND the user swipes the front card up or down, or presses Arrow Up/Down
- **THEN** the system SHALL shift the window of visible cards through the liked list

#### Scenario: Hide previous/next
- **WHEN** `/liked-users` is shown
- **THEN** the system SHALL NOT show previous/next arrows

#### Scenario: Hide list window arrows
- **WHEN** `/liked-users` is shown
- **THEN** the system SHALL NOT show up/down arrows

#### Scenario: Arrow pad diamond
- **WHEN** `/liked-users` is shown
- **THEN** the system SHALL NOT show an arrow pad

#### Scenario: Arrow pad vertical
- **WHEN** `/liked-users` is shown
- **THEN** the system SHALL NOT show stacked up/down arrow buttons

#### Scenario: Arrow pad horizontal
- **WHEN** `/liked-users` is shown
- **THEN** the system SHALL NOT show a previous/next arrow pair

#### Scenario: Bio drag still browses
- **WHEN** the pointer starts on the front card description
- **THEN** a swipe past the commit threshold SHALL still browse or shift the window

#### Scenario: No know or skip
- **WHEN** `/liked-users` is shown
- **THEN** the system SHALL NOT show I know this person or I’m not interested buttons
