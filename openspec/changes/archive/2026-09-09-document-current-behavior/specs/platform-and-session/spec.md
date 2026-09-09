## Purpose

[PRE] Captures the existing Catalyst Flutter web app platform: startup, API access, session persistence, route protection, and shared error handling.

## ADDED Requirements

### Requirement: Application platform
[PRE] The system SHALL start in a consistent web/mobile-style shell so users can use Catalyst in portrait without debug chrome.

#### Scenario: Orientation lock
- **WHEN** the app starts
- **THEN** [PRE] the system SHALL lock orientation to portrait up and portrait down

#### Scenario: Local cache before first route
- **WHEN** the app starts
- **THEN** [PRE] the system SHALL initialize local cache before showing the first route

#### Scenario: Splash is first route
- **WHEN** the app starts
- **THEN** [PRE] the system SHALL open the splash route `/`

#### Scenario: Debug banner hidden
- **WHEN** the app is running
- **THEN** [PRE] the system SHALL hide the Flutter debug banner

#### Scenario: Outside tap unfocuses
- **WHEN** the user taps outside a focused field
- **THEN** [PRE] the system SHALL unfocus the current input

#### Scenario: Web hash URLs
- **WHEN** the app is served on web
- **THEN** [PRE] named routes SHALL be hash URLs

### Requirement: API base URL
[PRE] The system SHALL set the API host at compile time so local and production builds can target different backends.

#### Scenario: Dart-define override
- **WHEN** `API_BASE_URL` is passed via `--dart-define`
- **THEN** [PRE] the system SHALL use that value as the API base URL

#### Scenario: Production default
- **WHEN** `API_BASE_URL` is omitted
- **THEN** [PRE] the system SHALL use `https://server.catalyst-app.org/api/v1`

#### Scenario: Local backend default
- **WHEN** a local backend is used
- **THEN** [PRE] the documented default local URL SHALL be `http://127.0.0.1:8000/api/v1`

### Requirement: Authenticated HTTP client
[PRE] The system SHALL send the access token on API calls and fail in a consistent way when the server cannot be reached or the session is invalid.

#### Scenario: Default JSON content type
- **WHEN** a request requires default headers
- **THEN** [PRE] the system SHALL send `Content-Type: application/json`

#### Scenario: Bearer token when present
- **WHEN** a request requires default headers AND an access token exists
- **THEN** [PRE] the system SHALL send `Authorization: Bearer <token>`

#### Scenario: Login form encoding
- **WHEN** a login request is sent
- **THEN** [PRE] the system SHALL send `application/x-www-form-urlencoded` without the Authorization header

#### Scenario: Optional headers omitted
- **WHEN** a request does not require default headers
- **THEN** [PRE] the system SHALL omit the Authorization header

#### Scenario: JSON success
- **WHEN** a request succeeds with HTTP 200 or 201
- **THEN** [PRE] the system SHALL decode JSON maps or lists from the body

#### Scenario: Empty success
- **WHEN** a request succeeds with HTTP 204
- **THEN** [PRE] the system SHALL treat the response as an empty map

#### Scenario: Timeout snackbar
- **WHEN** a request times out (default 5 seconds, LLM 30 seconds)
- **THEN** [PRE] the system SHALL show a top snackbar `Error` / `Could not reach the server. Please try again.` and return no payload

#### Scenario: Network error snackbar
- **WHEN** a socket or unexpected network error occurs
- **THEN** [PRE] the system SHALL show the same unreachable-server snackbar

#### Scenario: Rate limit
- **WHEN** the server returns HTTP 429
- **THEN** [PRE] the system SHALL show `Too many requests exception, please try again later!`

#### Scenario: Detail error snackbar
- **WHEN** the server returns HTTP 409 or another handled error with a `detail` field
- **THEN** [PRE] the system SHALL show that detail text in an `Error` snackbar

#### Scenario: FastAPI validation list
- **WHEN** FastAPI returns `detail` as a list of objects
- **THEN** [PRE] the system SHALL join each object's `msg` into the snackbar text

### Requirement: Session storage
[PRE] The system SHALL restore a returning user's access token on reload so they do not have to log in again.

#### Scenario: Persist token
- **WHEN** an access token is persisted
- **THEN** [PRE] the system SHALL store it in GetStorage database `catalyst_local_cache` under key `access_token`

#### Scenario: Restore token
- **WHEN** the app starts
- **THEN** [PRE] the system SHALL restore a non-empty trimmed `access_token` into memory

#### Scenario: Login persists session
- **WHEN** login succeeds
- **THEN** [PRE] the system SHALL persist `access_token` or `token` from the response and set local cache `user_logged_in_status` to logged in

#### Scenario: Clear session
- **WHEN** the session is cleared
- **THEN** [PRE] the system SHALL remove the access token, clear in-memory user state, reset onboarding complete to false, clear admin cookies, and set `user_logged_in_status` to logged out

#### Scenario: Empty token is unauthenticated
- **WHEN** `hasAccessToken` is evaluated
- **THEN** [PRE] the system SHALL treat a missing, empty, or whitespace-only token as unauthenticated

### Requirement: Role and admin session
[PRE] The system SHALL distinguish admin JWTs from member JWTs so admins cannot use member screens and members cannot use the admin console.

#### Scenario: Admin role
- **WHEN** a JWT payload contains `role` equal to `admin`
- **THEN** [PRE] the system SHALL treat the session as an admin session

#### Scenario: Decode failure is non-admin
- **WHEN** JWT payload decoding fails
- **THEN** [PRE] the system SHALL treat the session as non-admin

#### Scenario: Admin cookies on login
- **WHEN** an admin logs in
- **THEN** [PRE] the system SHALL also store `admin_token`, `admin_name`, and optional `admin_expires_at` cookies for 7 days on web

#### Scenario: Admin cookies cleared
- **WHEN** the session is cleared
- **THEN** [PRE] the system SHALL delete those admin cookies

### Requirement: Route protection
[PRE] The system SHALL bounce members without a token away from protected pages so private data is not shown.

#### Scenario: Member routes require token
- **WHEN** a user opens `/base`, `/idea-card`, `/settings`, `/initform`, or `/llm-choice` without an access token
- **THEN** [PRE] the system SHALL redirect to `/auth`

#### Scenario: Admin blocked from member routes
- **WHEN** an admin session opens those same member routes
- **THEN** [PRE] the system SHALL redirect to `/admin-welcome`

#### Scenario: Public routes skip auth middleware
- **WHEN** a user opens `/`, `/auth`, `/register`, `/verify`, `/recover-account`, `/reset-password`, `/admin`, `/admin-welcome`, or `/stacked-cards`
- **THEN** [PRE] AuthMiddleware SHALL not apply

#### Scenario: Logged-in users stay on public auth screens
- **WHEN** a member or admin who already has a token opens `/auth`, `/register`, `/recover-account`, `/verify`, `/reset-password`, or `/admin`
- **THEN** [PRE] the system SHALL leave them on that public screen and SHALL not bounce them to `/base` or `/admin-welcome`

#### Scenario: Invalid session redirect
- **WHEN** an API call returns HTTP 401, or HTTP 403 with detail `Could not validate credentials` or `Not authenticated`, except for `Email not verified` or invalid credentials
- **THEN** [PRE] the system SHALL clear the session and redirect to `/auth`, or `/admin` if the current route contains `admin`

#### Scenario: Not an admin token
- **WHEN** an API call returns detail `Not an admin token`
- **THEN** [PRE] the system SHALL navigate to `/admin`

#### Scenario: Admin helper forbidden
- **WHEN** an admin HTTP helper receives HTTP 403
- **THEN** [PRE] the system SHALL navigate to `/admin`

### Requirement: Named routes
[PRE] The system SHALL expose stable URLs for each screen so email links and bookmarks work.

#### Scenario: Route map
- **WHEN** the app maps screens
- **THEN** [PRE] the following named routes SHALL exist: `/` splash; `/register` register; `/auth` login; `/recover-account` recover account; `/verify` email verification; `/reset-password` reset password; `/initform` onboarding form; `/llm-choice` LLM description choice; `/base` member home shell; `/idea-card` My Card; `/settings` settings; `/stacked-cards` stacked cards (standalone, constructed with an empty user list); `/admin` admin login; `/admin-welcome` admin console

### Requirement: Unused product surface
[PRE] The system SHALL record unused modules so later specs do not treat them as live product.

#### Scenario: Live home UI
- **WHEN** documenting live member home
- **THEN** [PRE] the system SHALL treat `StackedCardsScreen` inside `/base` as the home UI, not the unused `HomeNavigationBar` / `home_view` / Appinio `swipe_cards` feature

#### Scenario: Direct stacked-cards route
- **WHEN** a user opens `/stacked-cards` directly
- **THEN** [PRE] the screen SHALL render with no users because the route constructs `StackedCardsScreen(users: [])`
