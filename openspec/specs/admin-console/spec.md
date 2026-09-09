# admin-console Specification

## Purpose

Captures the existing admin login and admin console: mailing HTML files, registration restrictions, and SQL table viewing.

## Requirements

### [PRE] Requirement: Admin login

The system SHALL provide a separate administrator login so they can reach the admin console.

#### Scenario: Login fields
- **WHEN** the user opens `/admin`
- **THEN** the system SHALL show Username *, Password *, and a login action

#### Scenario: Empty credentials
- **WHEN** username or password is empty
- **THEN** login SHALL show `Please enter a username and password.`

#### Scenario: Submit credentials
- **WHEN** credentials are submitted
- **THEN** the system SHALL POST `/admin/login` with `{ "username", "password" }` as JSON

#### Scenario: Login failure
- **WHEN** the response has no usable `access_token` or `token`
- **THEN** the system SHALL show `Admin login failed.` (or rely on the shared HTTP error snackbar)

#### Scenario: Login success
- **WHEN** login succeeds
- **THEN** the system SHALL persist the JWT as the app session, store admin cookies (`admin_token`, `admin_name` from `name` or username, `admin_expires_at` from JWT `exp` when present), and navigate to `/admin-welcome`

### [PRE] Requirement: Admin console access

The system SHALL require an admin JWT for the console so members cannot use it.

#### Scenario: Cookie restore
- **WHEN** `/admin-welcome` opens without a token
- **THEN** the system SHALL try `admin_token` from cookies

#### Scenario: No admin session
- **WHEN** there is still no admin session
- **THEN** the system SHALL navigate to `/admin`

#### Scenario: Console chrome
- **WHEN** the console is shown
- **THEN** the title SHALL be `Admin Welcome` and the sidebar SHALL list Mailing List, Registration Restrictions, and SQL Tables

#### Scenario: Default panel
- **WHEN** the console first loads
- **THEN** Registration Restrictions SHALL be selected and loaded

#### Scenario: Admin logout
- **WHEN** Logout is tapped
- **THEN** the system SHALL clear the session and navigate to `/admin`

### [PRE] Requirement: Registration restrictions

The system SHALL let an administrator edit registration restriction text so signup rules can be changed without a deploy.

#### Scenario: Load restrictions
- **WHEN** Registration Restrictions is selected
- **THEN** the system SHALL GET `/admin/restrictions` and put `text` into the editor

#### Scenario: Load failure
- **WHEN** that load fails
- **THEN** the system SHALL show `Could not load registration restrictions.`

#### Scenario: Save restrictions
- **WHEN** Save is tapped
- **THEN** the system SHALL PUT `/admin/restrictions` with `{ "text" }`

#### Scenario: Save success
- **WHEN** save succeeds
- **THEN** the system SHALL snackbar `Registration restrictions saved.`

#### Scenario: Save failure
- **WHEN** save fails
- **THEN** the system SHALL snackbar `Failed to save registration restrictions.`

### [PRE] Requirement: Mailing list files

The system SHALL let an administrator create, edit, preview, and delete HTML email files so they can manage mailings.

#### Scenario: List templates
- **WHEN** Mailing List is selected
- **THEN** the system SHALL GET `/admin/templates` and list names that end with `.html`

#### Scenario: List failure
- **WHEN** that list fails
- **THEN** the system SHALL show `Could not load mailing list pages.`

#### Scenario: Empty list
- **WHEN** the list is empty
- **THEN** the system SHALL show `No mailing list pages found.`

#### Scenario: Add file
- **WHEN** Add is used
- **THEN** the system SHALL prompt for a file name and PUT `/admin/templates/{name}` with `{ "text": "" }`

#### Scenario: Create success
- **WHEN** create succeeds
- **THEN** the system SHALL reload the list, select the new file when present, and snackbar `File "{name}" created successfully.`

#### Scenario: Create failure
- **WHEN** create fails
- **THEN** the system SHALL snackbar `Failed to create new file.`

#### Scenario: Load HTML
- **WHEN** a file is selected
- **THEN** the system SHALL GET `/admin/templates/{name}` as raw HTML

#### Scenario: HTML load failure
- **WHEN** HTML load fails
- **THEN** the system SHALL show `Could not load page HTML.`

#### Scenario: Empty HTML defaults to text
- **WHEN** HTML is empty
- **THEN** the default view SHALL be Text Only

#### Scenario: Non-empty HTML defaults to preview
- **WHEN** HTML is non-empty
- **THEN** the default view SHALL be Preview

#### Scenario: Text Only edit
- **WHEN** Text Only is active
- **THEN** the administrator SHALL edit HTML in a monospace field and can Save (PUT `{ "text" }`) or Remove after confirming `Are you sure you want to permanently remove "{name}"?`

#### Scenario: Preview
- **WHEN** Preview is active
- **THEN** the system SHALL render the current HTML in the HTML preview widget

#### Scenario: Select a page prompt
- **WHEN** no file is selected and files exist
- **THEN** the system SHALL show `Select a page to load its HTML content.`

#### Scenario: Empty welcome
- **WHEN** no files exist
- **THEN** the system SHALL show `Welcome {admin name}`

### [PRE] Requirement: Schedule a mailing

The system SHALL let an administrator schedule an HTML file to groups so mail can go out later.

#### Scenario: Load schedule
- **WHEN** Send is opened for a file
- **THEN** the system SHALL GET `/admin/templates/{name}/schedule` and apply returned `groups`, `date`, and `repeat` when valid

#### Scenario: Recipient group
- **WHEN** the send form is shown
- **THEN** the only recipient group SHALL be `All Users`, default-selected

#### Scenario: Send now disabled
- **WHEN** Send Now is shown
- **THEN** it SHALL be disabled with subtitle `Not available yet`

#### Scenario: Schedule later fields
- **WHEN** Schedule for later is selected
- **THEN** the administrator SHALL pick a date from today through five years ahead and a repeat of none / weekly / biweekly / monthly

#### Scenario: No group selected
- **WHEN** no group is selected
- **THEN** Schedule SHALL be disabled and attempting send SHALL snackbar `Select at least one recipient group.`

#### Scenario: Submit schedule
- **WHEN** Schedule is submitted
- **THEN** the system SHALL PUT `/admin/templates/{name}/schedule` with `{ "groups", "date" (ISO-8601), "repeat" }`

#### Scenario: Schedule success
- **WHEN** schedule succeeds
- **THEN** the system SHALL snackbar that the file was scheduled for that calendar date

#### Scenario: Send now blocked
- **WHEN** the send mode is `now`
- **THEN** the system SHALL not send and SHALL snackbar `Send now is not available yet.`

### [PRE] Requirement: SQL tables viewer

The system SHALL let an administrator inspect SQL tables so they can view live data without a separate database client.

#### Scenario: List tables
- **WHEN** SQL Tables is selected
- **THEN** the system SHALL GET `/admin/sql` and list table names

#### Scenario: List failure
- **WHEN** that list fails
- **THEN** the system SHALL show `Could not load SQL tables.`

#### Scenario: Empty tables
- **WHEN** the list is empty
- **THEN** the system SHALL show `No SQL tables found.`

#### Scenario: Load rows
- **WHEN** a table is tapped
- **THEN** the system SHALL GET `/admin/sql/rows?table={tableName}` and show a DataTable of `columns` and `rows`

#### Scenario: Table data failure
- **WHEN** table data fails
- **THEN** the system SHALL show `Could not load SQL table.`

#### Scenario: Select table prompt
- **WHEN** no table is selected and tables exist
- **THEN** the system SHALL show `Select a SQL table to load columns.`
