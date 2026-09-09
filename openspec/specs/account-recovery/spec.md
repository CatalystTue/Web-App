# account-recovery Specification

## Purpose

Captures existing account-recovery and password-reset behavior for Catalyst members.

## Requirements

### [PRE] Requirement: Request recovery email

The system SHALL let a user who forgot their password request a recovery email so they can set a new password.

#### Scenario: Recover fields
- **WHEN** the user opens `/recover-account`
- **THEN** the system SHALL show Email address and button `Recover your account`

#### Scenario: Invalid email
- **WHEN** email is empty or not a valid email
- **THEN** the system SHALL show `Please enter a valid email address.` and SHALL not call the API

#### Scenario: Submit recovery
- **WHEN** a valid email is submitted
- **THEN** the system SHALL POST `/recover` with `{ "email" }`

#### Scenario: Always-success copy
- **WHEN** that request finishes
- **THEN** the system SHALL always show `If this email exists, we will send you account recovery instructions.` and navigate to `/auth`

### [PRE] Requirement: Reset password from email link

The system SHALL let a user with a reset link set a new strong password so they can log in again.

#### Scenario: Read reset token
- **WHEN** `/reset-password` opens
- **THEN** the system SHALL read `token` from GetX parameters, `Uri.base` query, or the hash-fragment query

#### Scenario: Missing token
- **WHEN** no token is present
- **THEN** the system SHALL show `The reset link is invalid.` and SHALL not show the password form

#### Scenario: Password form
- **WHEN** a token is present
- **THEN** the system SHALL show Password * and Re-enter password * with visibility toggles and a `Reset Password` button

#### Scenario: Empty passwords
- **WHEN** either password field is empty
- **THEN** submit SHALL show `Please fill both password fields.`

#### Scenario: Weak password
- **WHEN** the new password does not match `^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$`
- **THEN** submit SHALL show `Password is not strong enough.`

#### Scenario: Mismatched passwords
- **WHEN** the two passwords differ
- **THEN** submit SHALL show `Passwords do not match.`

#### Scenario: Submit reset
- **WHEN** valid passwords are submitted
- **THEN** the system SHALL POST `/recover/reset` with `{ "token", "password" }`

#### Scenario: Reset success
- **WHEN** reset succeeds (response present and no `detail`)
- **THEN** the system SHALL show `Password updated successfully. Redirecting to login...` and after 2 seconds navigate to `/auth`

#### Scenario: Reset null response
- **WHEN** reset returns a null response
- **THEN** the system SHALL show `Could not reset password. The link may be invalid or expired.`

#### Scenario: Client-side token check
- **WHEN** a token string is non-empty
- **THEN** client-side token validation SHALL accept it without a dedicated token-check API call
