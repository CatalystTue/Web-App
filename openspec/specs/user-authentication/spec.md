# user-authentication Specification

## Purpose

Captures existing splash, registration, login, and email-verification behavior for Catalyst members.

## Requirements

### [PRE] Requirement: Splash routing

The system SHALL send returning users from splash to the right place so they resume where their session allows.

#### Scenario: Splash branding
- **WHEN** splash is shown
- **THEN** the system SHALL display the Catalyst logo and the copy `Unite, Motivate, Cooperate.`

#### Scenario: No token goes to login
- **WHEN** splash runs after first frame AND there is no access token
- **THEN** the system SHALL navigate to `/auth`

#### Scenario: Admin token goes to console
- **WHEN** splash runs AND the restored token is an admin session
- **THEN** the system SHALL navigate to `/admin-welcome`

#### Scenario: Member profile load
- **WHEN** splash runs AND a member token exists
- **THEN** the system SHALL GET `/profile/me` and set `onboarding_complete` from `onboarding_complete == true`

#### Scenario: Onboarded member goes home
- **WHEN** that member has completed onboarding
- **THEN** the system SHALL navigate to `/base`

#### Scenario: Incomplete onboarding
- **WHEN** that member has not completed onboarding
- **THEN** the system SHALL navigate to `/initform`

#### Scenario: Splash uses member token only
- **WHEN** splash restores a session
- **THEN** the system SHALL use only GetStorage `access_token` and SHALL not read admin cookies

### [PRE] Requirement: Registration form

The system SHALL let a new user register with email, password, and legal consent so they can create an account.

#### Scenario: Register fields
- **WHEN** the user opens `/register`
- **THEN** the system SHALL show fields Email *, Password *, Re-enter Password *, a Terms/Privacy checkbox, a Register button, and a link to login

#### Scenario: Live password checks
- **WHEN** the password field changes
- **THEN** the system SHALL show live checks for: at least 8 characters; one lowercase letter; one uppercase letter; one number; one symbol from `@ $ ! % * ? &`; only letters, numbers, and those symbols

#### Scenario: Legal documents
- **WHEN** the user taps Terms of Use or Privacy Notice
- **THEN** the system SHALL open `legal/terms_of_use.pdf` or `legal/privacy_notice.pdf` in a new browser tab on web

#### Scenario: Invalid register input
- **WHEN** email is invalid, passwords are weak or mismatched, fields are empty, or the checkbox is unchecked
- **THEN** Register SHALL show `Please fill all the required fields correctly`, SHALL turn the checkbox border red, and SHALL not call the API

#### Scenario: Valid register submit
- **WHEN** Register is submitted with valid input
- **THEN** the system SHALL POST `/users` with `{ "email", "password" }` and disable the button while loading

#### Scenario: Register success
- **WHEN** registration succeeds without a `detail` error
- **THEN** the system SHALL show a dialog titled `Verify your email` with copy that a verification link will be sent if the email exists, then navigate to `/auth`

#### Scenario: Register no response
- **WHEN** registration returns no response
- **THEN** the system SHALL show `Registration failed. Please try again.`

#### Scenario: Login link
- **WHEN** the user chooses Login here
- **THEN** the system SHALL navigate to `/auth`

### [PRE] Requirement: Login

The system SHALL let a registered user log in with email and password so they can use the member app.

#### Scenario: Login fields
- **WHEN** the user opens `/auth`
- **THEN** the system SHALL show Email address, Password, Login, Forgot your password? Reset it here, and Don't have an account? Register here

#### Scenario: Invalid login input
- **WHEN** email is empty, not an email, or password is empty
- **THEN** Login SHALL show `Enter a valid email and password.` and SHALL not call the API

#### Scenario: Valid login submit
- **WHEN** Login is submitted with valid input
- **THEN** the system SHALL POST `/login` as form-urlencoded `username` + `password` and ignore duplicate taps while loading

#### Scenario: Login success
- **WHEN** the response contains a non-empty `access_token` or `token`
- **THEN** the system SHALL persist the session, refresh onboarding status from `/profile/me`, and navigate to `/base` or `/initform`

#### Scenario: Invalid credentials
- **WHEN** the server returns `Invalid email or password` or `Invalid username or password`
- **THEN** the system SHALL show snackbar `Login failed` with that text

#### Scenario: Unverified email
- **WHEN** the server returns `Email not verified`
- **THEN** the system SHALL keep the user on login, show `Email not verified`, and offer `Resend verification email`

#### Scenario: Register here
- **WHEN** the user taps Register here
- **THEN** the system SHALL navigate to `/register`

#### Scenario: Password recovery link
- **WHEN** the user taps password recovery
- **THEN** the system SHALL navigate to `/recover-account`

### [PRE] Requirement: Resend verification from login

The system SHALL let an unverified user resend the verification email from login so they can complete signup.

#### Scenario: Invalid resend email
- **WHEN** resend is tapped with an empty or invalid email
- **THEN** the system SHALL show `Enter a valid email to resend verification.`

#### Scenario: Resend request
- **WHEN** resend is tapped with a valid email
- **THEN** the system SHALL POST `/verify/resend` with `{ "email" }`

#### Scenario: Resend success copy
- **WHEN** that request returns a body without `detail`
- **THEN** the system SHALL show `If this email exists, we will send you a verification link.`

### [PRE] Requirement: Email verification landing page

The system SHALL let the verification link in email confirm the account so the user can log in.

#### Scenario: Read verification token
- **WHEN** `/verify` opens
- **THEN** the system SHALL read `token` from GetX parameters, `Uri.base` query, or the hash-fragment query

#### Scenario: Missing token
- **WHEN** no token is present
- **THEN** the system SHALL show `Verification failed` and `Verification token is missing or invalid.` plus `Go to login`

#### Scenario: Verify in progress
- **WHEN** a token is present
- **THEN** the system SHALL POST `/verify` with `{ "token" }` while showing `Verifying your email...`

#### Scenario: Verify success
- **WHEN** verification succeeds (response present and no `detail`)
- **THEN** the system SHALL show `Your email has been verified. You can now log in.` and after 3 seconds navigate to `/auth`

#### Scenario: Verify failure
- **WHEN** verification fails
- **THEN** the system SHALL show `Verification failed. Please request a new verification link.`

#### Scenario: Go to login
- **WHEN** the user taps `Go to login`
- **THEN** the system SHALL navigate to `/auth`
