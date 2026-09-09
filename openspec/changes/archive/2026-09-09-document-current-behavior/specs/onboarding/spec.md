## Purpose

[PRE] Captures existing first-time profile onboarding: the init form and optional LLM-drafted description.

## ADDED Requirements

### Requirement: Access
[PRE] The system SHALL gate onboarding behind the member session so only that member can complete their profile.

#### Scenario: Missing token
- **WHEN** `/initform` or `/llm-choice` is opened without an access token
- **THEN** [PRE] the system SHALL redirect to `/auth`

#### Scenario: Admin redirected
- **WHEN** an admin session opens those routes
- **THEN** [PRE] the system SHALL redirect to `/admin-welcome`

### Requirement: Init form fields
[PRE] The system SHALL let a new member enter who they are so other users can see their card.

#### Scenario: Form title and fields
- **WHEN** `/initform` opens
- **THEN** [PRE] the system SHALL title the screen `Your information` and show Name, Affiliation, Position / career stage, Location, Description, and Keywords

#### Scenario: Position options
- **WHEN** Position / career stage is shown
- **THEN** [PRE] the options SHALL be: PhD Student; Postdoctoral researcher; Junior Professor; Professor; Student; Academic Staff; Group Leader; Other

#### Scenario: Affiliation search
- **WHEN** the user types 3 or more characters in Affiliation
- **THEN** [PRE] after 400ms the system SHALL GET `/profile/affiliations?q=` and show suggestions with `label` and subtitle `country_name - name`

#### Scenario: Short affiliation query
- **WHEN** the query is shorter than 3 characters
- **THEN** [PRE] affiliation suggestions SHALL be cleared

#### Scenario: Select affiliation
- **WHEN** the user selects a suggestion
- **THEN** [PRE] the affiliation field SHALL be set to that option's `label`

#### Scenario: Keywords helper
- **WHEN** Keywords helper copy is shown
- **THEN** [PRE] it SHALL say that keywords can be used instead of writing a description so AI can draft one

#### Scenario: Add keyword chip
- **WHEN** the user adds a non-empty keyword that is not already selected
- **THEN** [PRE] the system SHALL add it as a removable chip and clear the keyword field

#### Scenario: Continue flushes keyword field
- **WHEN** Continue is pressed
- **THEN** [PRE] any non-empty keyword still in the text field SHALL be added first

### Requirement: Init form submit
[PRE] The system SHALL save what the member entered on Continue and either finish onboarding or generate description drafts.

#### Scenario: Empty name
- **WHEN** name is empty
- **THEN** [PRE] Continue SHALL show `Please enter your name.` and SHALL not save

#### Scenario: Empty description and keywords
- **WHEN** description is empty AND there are no keywords
- **THEN** [PRE] Continue SHALL show `Please enter a description or at least one keyword.`

#### Scenario: Save without keywords
- **WHEN** Continue is valid AND there are no keywords
- **THEN** [PRE] the system SHALL PATCH `/profile/me` with filled non-empty fields and `onboarding_complete: true`, then navigate to `/base`

#### Scenario: Keywords trigger LLM
- **WHEN** Continue is valid AND keywords exist
- **THEN** [PRE] the system SHALL PATCH `/profile/me` with filled non-empty fields without marking onboarding complete, then POST `/profile/llm` with `{ "keywords" }` using a 30-second timeout

#### Scenario: LLM drafts
- **WHEN** the LLM response includes `draft_1` and `draft_2`
- **THEN** [PRE] the system SHALL navigate to `/llm-choice` with those drafts (also aliased as `string1` / `string2`)

#### Scenario: Profile save failure
- **WHEN** profile save fails
- **THEN** [PRE] the system SHALL show `Could not save your profile. Please try again.`

#### Scenario: LLM fetch failure
- **WHEN** LLM fetch fails
- **THEN** [PRE] the system SHALL show `Could not fetch suggestions. Please try again.` and remain on the init form

#### Scenario: Saving state
- **WHEN** Continue is in progress
- **THEN** [PRE] the button SHALL show `Saving...` and ignore extra taps

### Requirement: LLM description choice
[PRE] The system SHALL let a new member pick or write a profile description from AI drafts so their card has usable copy.

#### Scenario: Choice title
- **WHEN** `/llm-choice` opens
- **THEN** [PRE] the system SHALL title the screen `Choose Your Preference` and ask which description the user prefers

#### Scenario: Draft options
- **WHEN** drafts are present
- **THEN** [PRE] the system SHALL list each non-empty draft plus a final option `Write your own description...`

#### Scenario: Continue disabled
- **WHEN** no option is selected
- **THEN** [PRE] `Continue and Edit` SHALL be disabled

#### Scenario: Enter edit step
- **WHEN** the user continues from the list
- **THEN** [PRE] the system SHALL enter an edit step with the chosen draft, or an empty field for the custom option

#### Scenario: Empty edit description
- **WHEN** the edit-step description is empty
- **THEN** [PRE] Continue SHALL show `Please write a description before continuing.`

#### Scenario: Finalize description
- **WHEN** the edit-step description is non-empty
- **THEN** [PRE] the system SHALL PATCH `/profile/me` with that `description` and `onboarding_complete: true`, then navigate to `/base`

#### Scenario: Finalize save failure
- **WHEN** that save fails
- **THEN** [PRE] the system SHALL show `Could not save your profile. Please try again.`

#### Scenario: Back to init form
- **WHEN** the user uses the app-bar back control before a successful finalize
- **THEN** [PRE] the system SHALL return to `/initform` because `/llm-choice` was pushed, not replaced
