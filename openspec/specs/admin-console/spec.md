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

#### Scenario: Submit with Enter
- **WHEN** the administrator presses Enter in the password field
- **THEN** the system SHALL submit login the same way as the login action

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
- **THEN** the title SHALL be `Admin Welcome` and the sidebar SHALL list Mailing List, Mail Plans, Registration Restrictions, User Links, and SQL Tables

#### Scenario: Default panel
- **WHEN** the console first loads
- **THEN** Registration Restrictions SHALL be selected and loaded

#### Scenario: Admin logout
- **WHEN** Logout is tapped
- **THEN** the system SHALL clear the session and navigate to `/admin`

### [PRE] Requirement: Registration restrictions

The system SHALL let an administrator add, edit, and remove allowed registration domains so signup rules can be changed without a deploy.

#### Scenario: Load domains
- **WHEN** Registration Restrictions is selected
- **THEN** the system SHALL GET `/admin/restrictions` and list the returned `domains`

#### Scenario: Empty list
- **WHEN** the list is empty
- **THEN** the system SHALL show `No registration domains.` and SHALL NOT treat that as a load failure

#### Scenario: Load failure
- **WHEN** that load fails
- **THEN** the system SHALL show `Could not load registration restrictions.`

#### Scenario: Add domain
- **WHEN** Add is used with a non-empty domain
- **THEN** the system SHALL POST `/admin/restrictions` with `{ "domain" }` and refresh the list on success

#### Scenario: Add success
- **WHEN** add succeeds
- **THEN** the system SHALL snackbar `Domain added.`

#### Scenario: Edit domain
- **WHEN** an existing domain is edited with a non-empty replacement
- **THEN** the system SHALL PUT `/admin/restrictions/{domain}` with `{ "domain" }` using the current stored hostname in the path, and refresh the list on success

#### Scenario: Edit success
- **WHEN** edit succeeds
- **THEN** the system SHALL snackbar `Domain updated.`

#### Scenario: Remove domain
- **WHEN** an existing domain is removed
- **THEN** the system SHALL DELETE `/admin/restrictions/{domain}` and refresh the list on success

#### Scenario: Remove success
- **WHEN** remove succeeds
- **THEN** the system SHALL snackbar `Domain removed.`

#### Scenario: Mutation failure
- **WHEN** add, edit, or remove fails
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

### Requirement: Admin can search users

When User Links is selected, the system SHALL let an administrator search users in two picker fields (user and other user) the same way affiliation search works: typing SHALL GET `/admin/users` with optional query `q` (substring on affiliation, name, or email) without requiring Enter. Each picker SHALL show matching rows (`id`, `name`, `affiliation`, `email`). Tapping a row SHALL select that user for that field. Search SHALL NOT use typed numeric user ids as the way to choose people.

#### Scenario: Load User Links
- **WHEN** User Links is selected
- **THEN** the system SHALL show two user search pickers

#### Scenario: Search users
- **WHEN** the administrator types in a picker
- **THEN** the system SHALL GET `/admin/users` with that `q` and show matching rows under that picker without requiring Enter

#### Scenario: Pick a user
- **WHEN** the administrator taps a search result
- **THEN** that picker SHALL show the selected user and use that user's id for create-link

#### Scenario: Search failure
- **WHEN** the user list request fails
- **THEN** the system SHALL show `Could not load users.`

#### Scenario: Empty search results
- **WHEN** the list is empty
- **THEN** the system SHALL show `No users found.`

### Requirement: Admin can create a user link

The system SHALL let an administrator post two user ids into the link table from the two pickers. Submit SHALL POST `/admin/links` with `{ "user_id", "other_id" }` as integers from the selected users. Same user twice SHALL snackbar the server detail (HTTP 400). A missing user SHALL snackbar the server detail (HTTP 404). A pair that is already stored SHALL snackbar the server detail (HTTP 409).

#### Scenario: Create link
- **WHEN** two distinct selected users are submitted
- **THEN** the system SHALL POST `/admin/links` with those ids

#### Scenario: Create success
- **WHEN** create succeeds
- **THEN** the system SHALL snackbar `Link created.`

#### Scenario: Missing ids
- **WHEN** either picker has no selected user
- **THEN** the system SHALL snackbar `Select two users.` and SHALL NOT POST `/admin/links`

### Requirement: Admin can delete a user link

The system SHALL let an administrator delete a link by the row id shown in SQL Tables. Delete SHALL DELETE `/admin/links/{id}`. Unknown id SHALL snackbar the server detail (HTTP 404). Delete SHALL NOT claim that mail was revoked.

#### Scenario: Delete link
- **WHEN** an existing link id is submitted for delete
- **THEN** the system SHALL DELETE `/admin/links/{id}`

#### Scenario: Delete success
- **WHEN** delete succeeds
- **THEN** the system SHALL snackbar `Link deleted.`

#### Scenario: Missing delete id
- **WHEN** the delete id is empty or not an integer
- **THEN** the system SHALL snackbar `Enter a link id.` and SHALL NOT DELETE

### Requirement: Admin can send intro mail

The system SHALL let an administrator send remaining intro mail from the User Links panel. Send SHALL POST `/admin/links/send` only after the administrator confirms in a Yes/No dialog, then snackbar the returned `sent` count. Send SHALL NOT open a new digest page; mail CTAs stay on public `/digest`.

#### Scenario: Confirm send
- **WHEN** Send intros is tapped
- **THEN** the system SHALL show `Are you sure?` with Yes and No and SHALL NOT POST `/admin/links/send` yet

#### Scenario: Cancel send
- **WHEN** No is tapped
- **THEN** the system SHALL close the dialog and SHALL NOT POST `/admin/links/send`

#### Scenario: Send intros
- **WHEN** Yes is tapped
- **THEN** the system SHALL POST `/admin/links/send`

#### Scenario: Send success
- **WHEN** send returns `{ "sent": N }`
- **THEN** the system SHALL snackbar `Sent N intro mail(s).`

#### Scenario: Send failure
- **WHEN** send fails
- **THEN** the system SHALL snackbar `Failed to send intro mail.`

### Requirement: Admin can load and save mail plans

When Mail Plans is selected, the system SHALL GET `/admin/mail/digest` and GET `/admin/mail/intro` and show two sections: Interest digest and Intro mail. Digest SHALL include enabled, frequency of daily / weekly / biweekly / monthly, and a date calendar for `next_at`. Digest SHALL NOT include a time picker. Digest save SHALL PUT `/admin/mail/digest` with `{ "enabled", "repeat", "next_at" }` where `next_at` is the selected calendar date (UTC noon ISO-8601 with `Z`); the server stamps send time. Intro SHALL include enabled, a date calendar for `next_at`, Save, and Send now, and SHALL NOT include a time picker or a repeat control. Intro save SHALL PUT `/admin/mail/intro` with `{ "enabled", "next_at" }` and SHALL NOT send `repeat`; when intro is disabled, `next_at` MAY be null. Send now SHALL confirm in a Yes/No dialog then POST `/admin/links/send` and snackbar the returned `sent` count. The Mail Plans panel SHALL NOT call a digest send-now path. When a plan is enabled and the selected date is before today, the system SHALL NOT PUT that plan.

#### Scenario: Load Mail Plans
- **WHEN** Mail Plans is selected
- **THEN** the system SHALL GET `/admin/mail/digest` and GET `/admin/mail/intro` and show Interest digest and Intro mail

#### Scenario: Digest load failure
- **WHEN** the digest GET fails
- **THEN** the system SHALL show `Could not load digest plan.`

#### Scenario: Intro load failure
- **WHEN** the intro GET fails
- **THEN** the system SHALL show `Could not load intro plan.`

#### Scenario: Save digest
- **WHEN** digest Save is used with enabled, a valid frequency, and a date that is today or later
- **THEN** the system SHALL PUT `/admin/mail/digest` with `{ "enabled", "repeat", "next_at" }`

#### Scenario: Digest save success
- **WHEN** digest save succeeds
- **THEN** the system SHALL snackbar `Digest plan saved.`

#### Scenario: Save intro
- **WHEN** intro Save is used with enabled and a date that is today or later
- **THEN** the system SHALL PUT `/admin/mail/intro` with `{ "enabled", "next_at" }` and SHALL NOT include `repeat`

#### Scenario: Intro save success
- **WHEN** intro save succeeds
- **THEN** the system SHALL snackbar `Intro plan saved.` and reload the intro plan

#### Scenario: Enabled date before today
- **WHEN** Save is used on an enabled plan whose date is before today
- **THEN** the system SHALL NOT PUT that plan

#### Scenario: No digest send-now
- **WHEN** Mail Plans is shown
- **THEN** the system SHALL NOT offer a digest send-now action and SHALL NOT request `/admin/mail/digest/send`

#### Scenario: Intro send now
- **WHEN** Send now is used and confirmed
- **THEN** the system SHALL POST `/admin/links/send` and snackbar `Sent N intro mail(s).` or `Failed to send intro mail.`

### Requirement: Mail HTML preview shows the bundled lockup

When Preview is active, the HTML preview widget SHALL display this app's `assets/png/catalyst_logo.png` for the public mail lockup URLs `https://app.catalyst-app.org/assets/assets/png/catalyst_logo.png` and `https://app.catalyst-app.org/assets/png/catalyst_logo.png`. Other HTML SHALL stay unchanged. Stored template text SHALL keep the hotlink.

#### Scenario: Preview uses bundled lockup
- **WHEN** Preview is active and the HTML includes either public lockup URL
- **THEN** the rendered preview SHALL use `assets/png/catalyst_logo.png` from this app

#### Scenario: Save keeps the hotlink
- **WHEN** the administrator saves mailing HTML that includes a public lockup URL
- **THEN** the stored HTML SHALL still contain that URL
