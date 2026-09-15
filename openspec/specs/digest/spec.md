# digest Specification

## Purpose

Logged-out digest mail landing: consume a token and outcome on load, then show thanks or an error without claiming a match or showing the other person's email.

## Requirements

### Requirement: Public digest route

The system SHALL expose `/digest` as a hash route with no AuthMiddleware so mail CTAs work while logged out.

#### Scenario: Route is public
- **WHEN** a user opens `/digest` without an access token
- **THEN** AuthMiddleware SHALL not apply and the digest screen SHALL load

#### Scenario: Login link
- **WHEN** thanks or error is shown
- **THEN** the system SHALL offer a control that navigates to `/auth`

### Requirement: Consume on load

On load the system SHALL parse `token` and `outcome` from GetX parameters, `Uri.base`, or the hash query, then POST `/digest` with `{ "token", "outcome" }` and `requiredDefaultHeader: false`. `outcome` SHALL be one of `interest`, `no_interest`, and `know`. HTTP 204 SHALL be treated as an empty success map.

#### Scenario: Valid consume
- **WHEN** the page loads with a valid token and outcome
- **THEN** the system SHALL POST `/digest` without a bearer token and, on 204, show a thanks state

#### Scenario: Loading
- **WHEN** the consume request is in flight
- **THEN** the system SHALL show a loading indicator

#### Scenario: Missing params
- **WHEN** token or a valid outcome is missing
- **THEN** the system SHALL show an in-page error and SHALL NOT POST `/digest`

### Requirement: Thanks does not claim a match

The thanks UI SHALL NOT say the member matched and SHALL NOT show the other person's email.

#### Scenario: Thanks copy
- **WHEN** consume succeeds with 204
- **THEN** the system SHALL thank the user for recording a response and SHALL NOT mention a match or an email address

### Requirement: Consume errors

The system SHALL show an in-page error for failed consume. An existing Error snackbar for HTTP 409 MAY also appear.

#### Scenario: Invalid or expired
- **WHEN** the server returns HTTP 400 with detail `Invalid or expired token`
- **THEN** the system SHALL show an in-page error for that invalid or expired token

#### Scenario: Already responded
- **WHEN** the server returns HTTP 409
- **THEN** the system SHALL show an in-page already-responded error
