## Purpose

[PRE] Captures existing My Card, settings, legal documents, logout, and account deletion.

## ADDED Requirements

### Requirement: Open profile from settings
[PRE] The system SHALL give a member a settings page with profile and account actions so they can manage their card and session.

#### Scenario: Settings requires token
- **WHEN** `/settings` is opened without an access token
- **THEN** [PRE] the system SHALL redirect to `/auth`

#### Scenario: Settings rows
- **WHEN** settings opens
- **THEN** [PRE] the system SHALL show Profile, Terms of Use, Privacy Notice, Delete Account, and Logout

#### Scenario: Profile navigation
- **WHEN** Profile is tapped
- **THEN** [PRE] the system SHALL navigate to `/idea-card`

#### Scenario: Terms of Use
- **WHEN** Terms of Use is tapped
- **THEN** [PRE] the system SHALL open `legal/terms_of_use.pdf` in a new tab on web

#### Scenario: Privacy Notice
- **WHEN** Privacy Notice is tapped
- **THEN** [PRE] the system SHALL open `legal/privacy_notice.pdf` in a new tab on web

### Requirement: View My Card
[PRE] The system SHALL let a member see their own card so they know how they appear to others.

#### Scenario: Load card
- **WHEN** `/idea-card` opens
- **THEN** [PRE] the system SHALL GET `/profile/me` and show a loading indicator until it returns

#### Scenario: Card fields
- **WHEN** the card is shown
- **THEN** [PRE] it SHALL list Name, Affiliation, Position, Location, and Description, using `—` for empty values

#### Scenario: Edit icon
- **WHEN** loading finishes
- **THEN** [PRE] an edit icon SHALL appear in the app bar

### Requirement: Edit My Card
[PRE] The system SHALL let a member edit their card fields so their public profile stays current.

#### Scenario: Edit fields
- **WHEN** edit is tapped
- **THEN** [PRE] the system SHALL show fields Name, Affiliation, Position, Location, and Description, plus Cancel and Save

#### Scenario: Affiliation search
- **WHEN** Affiliation has 3 or more characters
- **THEN** [PRE] after 400ms the system SHALL GET `/profile/affiliations?q=` and show selectable suggestions

#### Scenario: Cancel edit
- **WHEN** Cancel is tapped
- **THEN** [PRE] the system SHALL restore the last loaded values and leave edit mode

#### Scenario: Save card
- **WHEN** Save is tapped
- **THEN** [PRE] the system SHALL PATCH `/profile/me` with the trimmed field values, including empty strings so fields can be cleared

#### Scenario: Save success
- **WHEN** save succeeds
- **THEN** [PRE] the system SHALL update the displayed card and leave edit mode

#### Scenario: Save failure
- **WHEN** save fails
- **THEN** [PRE] the system SHALL show `Could not save your card. Please try again.` and stay in edit mode

#### Scenario: Saving state
- **WHEN** Save is in progress
- **THEN** [PRE] the button SHALL show `Saving...` and ignore extra taps

### Requirement: Logout
[PRE] The system SHALL let a member log out so this browser no longer uses their session.

#### Scenario: Logout
- **WHEN** Logout is tapped
- **THEN** [PRE] the system SHALL clear the session and navigate to splash `/`

### Requirement: Delete account
[PRE] The system SHALL let a member permanently delete their account after confirming so their data is removed.

#### Scenario: Confirm dialog
- **WHEN** Delete Account is tapped
- **THEN** [PRE] the system SHALL show a non-dismissible dialog `Are you sure?` with copy `This permanently deletes your account and cannot be undone.` and Cancel / Delete

#### Scenario: Cancel delete
- **WHEN** Cancel is chosen
- **THEN** [PRE] the system SHALL close the dialog and SHALL not call the API

#### Scenario: Confirm delete
- **WHEN** Delete is confirmed
- **THEN** [PRE] the system SHALL DELETE `/users/me`

#### Scenario: Delete success
- **WHEN** delete succeeds (response present and no `detail`)
- **THEN** [PRE] the system SHALL erase local cache, clear user and token, and navigate to splash `/`

#### Scenario: Delete does not clear admin cookies
- **WHEN** delete succeeds
- **THEN** [PRE] the system SHALL not call `CookieStorage.clearAdminSession` (unlike logout/clearSession)

#### Scenario: Delete failure
- **WHEN** delete fails AND an access token is still present
- **THEN** [PRE] the system SHALL show `Could not delete your account. Please try again.`
