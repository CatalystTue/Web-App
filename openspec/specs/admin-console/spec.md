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
- **THEN** the title SHALL be `Admin Welcome` and the sidebar SHALL list Mailing List, Assets, Registration Restrictions, User Links, and SQL Tables

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

### Requirement: Admin can list assets

When Assets is selected, the system SHALL GET `/admin/assets` and list the returned file names.

#### Scenario: Load Assets
- **WHEN** Assets is selected
- **THEN** the system SHALL GET `/admin/assets` and show the names

#### Scenario: List failure
- **WHEN** that list fails
- **THEN** the system SHALL show `Could not load assets.`

#### Scenario: Empty list
- **WHEN** the list is empty
- **THEN** the system SHALL show `No assets found.`

### Requirement: Admin can add an asset

The system SHALL let an administrator upload a file. Upload SHALL PUT `/admin/assets/{name}` as multipart field `file`. The name SHALL be a single path segment: not empty, not `.` or `..`, not starting with `.`, and with no `/` or `\`. Invalid names SHALL snackbar `Invalid asset name.` and SHALL NOT PUT.

#### Scenario: Add asset
- **WHEN** a file is chosen with a valid name
- **THEN** the system SHALL PUT `/admin/assets/{name}` with that file as `file`

#### Scenario: Add success
- **WHEN** create or replace succeeds
- **THEN** the system SHALL reload the list, select that name when present, and snackbar `Asset "{name}" saved.`

#### Scenario: Add failure
- **WHEN** upload fails
- **THEN** the system SHALL snackbar `Failed to save asset.`

#### Scenario: Invalid add name
- **WHEN** the name is empty, `.`, `..`, starts with `.`, or contains `/` or `\`
- **THEN** the system SHALL snackbar `Invalid asset name.` and SHALL NOT PUT

### Requirement: Admin can preview and copy an asset name

When a listed asset is selected, the system SHALL GET `/admin/assets/{name}` as bytes (admin JWT). Image bytes SHALL preview. Copy name SHALL put the filename on the clipboard so it can be pasted into mailing HTML.

#### Scenario: Load asset
- **WHEN** a name is selected
- **THEN** the system SHALL GET `/admin/assets/{name}` as bytes

#### Scenario: Image preview
- **WHEN** the bytes are a png, jpeg, gif, or webp image
- **THEN** the system SHALL show that image

#### Scenario: Non-image selected
- **WHEN** the bytes are not those image types
- **THEN** the system SHALL show `No preview for this file.`

#### Scenario: Load failure
- **WHEN** GET fails
- **THEN** the system SHALL show `Could not load asset.`

#### Scenario: Copy name
- **WHEN** Copy name is tapped for a selected file
- **THEN** the system SHALL copy that filename to the clipboard and snackbar `Copied "{name}".`

### Requirement: Admin can rename an asset

The system SHALL let an administrator change a selected file's name. Rename SHALL PUT `/admin/assets/{newName}` with the current bytes as multipart `file`, then DELETE `/admin/assets/{oldName}` when the names differ. The new name SHALL use the same path-safety rules as add. Same name SHALL snackbar `Enter a new name.` and SHALL NOT PUT or DELETE.

#### Scenario: Rename asset
- **WHEN** a valid new name different from the current name is submitted
- **THEN** the system SHALL PUT the bytes under the new name and DELETE the old name

#### Scenario: Rename success
- **WHEN** rename succeeds
- **THEN** the system SHALL reload the list, select the new name when present, and snackbar `Asset renamed to "{newName}".`

#### Scenario: Rename failure
- **WHEN** PUT or DELETE fails
- **THEN** the system SHALL snackbar `Failed to rename asset.`

#### Scenario: Same name
- **WHEN** the new name equals the current name
- **THEN** the system SHALL snackbar `Enter a new name.` and SHALL NOT PUT or DELETE

#### Scenario: Invalid rename name
- **WHEN** the new name is empty, `.`, `..`, starts with `.`, or contains `/` or `\`
- **THEN** the system SHALL snackbar `Invalid asset name.` and SHALL NOT PUT or DELETE

### Requirement: Admin can delete an asset

The system SHALL let an administrator delete a selected file after confirming `Are you sure you want to permanently remove "{name}"?`. Delete SHALL DELETE `/admin/assets/{name}`. Missing file SHALL snackbar the server detail (HTTP 404).

#### Scenario: Delete asset
- **WHEN** the administrator confirms delete for a selected name
- **THEN** the system SHALL DELETE `/admin/assets/{name}`

#### Scenario: Delete cancelled
- **WHEN** the administrator declines the confirm dialog
- **THEN** the system SHALL NOT DELETE

#### Scenario: Delete success
- **WHEN** delete succeeds
- **THEN** the system SHALL reload the list and snackbar `Asset "{name}" removed.`

#### Scenario: Delete failure
- **WHEN** delete fails
- **THEN** the system SHALL snackbar `Failed to remove asset.`
