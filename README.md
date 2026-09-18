# catalyst_flutter_app

Flutter web frontend for Catalyst. Members sign in, complete a profile card, and browse a stack of other users. Admins have a separate console.

Current behavior is specified in [`openspec/specs/`](openspec/specs/). `[PRE]` on a requirement means it was reverse-engineered from this codebase, not new work.

## Getting Started

Operator knobs live in committed `assets/.env` (loaded at startup from `lib/Core/Constants/config.dart`):

```
API_BASE_URL=https://server.catalyst-app.org/api
FEEDBACK_FORM_URL=https://catalyst-app.org/?page_id=339
FEEDBACK_SWIPE_THRESHOLD=100
```

Edit the file and rebuild. Missing keys use those same defaults. `--dart-define=API_BASE_URL=...` still overrides the file so local run does not require a git change.

Run locally against a local backend (start the backend first, typically `http://127.0.0.1:8000`). Omit `--dart-define=API_BASE_URL` to use `assets/.env`.

Chrome (opens a real browser):

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

Cursor Simple Browser (or any other client): serve without launching Chrome, then open the printed URL (`Cmd+Shift+P` → **Simple Browser: Show**):

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080 --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

One `flutter run` can be opened in Chrome and Cursor at the same time. Those browsers keep separate GetStorage sessions (you can log in as two users). Two tabs in the same browser share one session. Use a second `flutter run` with a different `--web-port` only if you need two builds or API targets.

Build the web app (uses `assets/.env` unless you pass `--dart-define=API_BASE_URL`):

```bash
flutter build web --release
```

## Pages

Named routes in `lib/Core/Constants/route.dart`. On web they are hash URLs (`/#/auth`). Not all pages are public.

| Path | Screen |
| --- | --- |
| `/` | Splash |
| `/register` | Register |
| `/auth` | Login |
| `/recover-account` | Recover account |
| `/verify` | Verify |
| `/reset-password` | Reset password |
| `/initform` | Onboarding form |
| `/llm-choice` | LLM choice |
| `/base` | Main app shell |
| `/idea-card` | My Card |
| `/settings` | Settings |
| `/stacked-cards` | Stacked cards |
| `/liked-users` | Liked users |
| `/digest` | Digest mail landing |
| `/admin` | Admin login |
| `/admin-welcome` | Admin area |

## Specs

| Capability | Covers |
| --- | --- |
| [platform-and-session](openspec/specs/platform-and-session/spec.md) | App shell, API client, tokens, routing, auth gates |
| [user-authentication](openspec/specs/user-authentication/spec.md) | Splash, register, login, email verification |
| [account-recovery](openspec/specs/account-recovery/spec.md) | Recover account and reset password |
| [onboarding](openspec/specs/onboarding/spec.md) | Profile init form and LLM description choice |
| [matching-stack](openspec/specs/matching-stack/spec.md) | Home card, likes, undo, liked-users page |
| [digest](openspec/specs/digest/spec.md) | Logged-out digest mail landing |
| [profile-and-settings](openspec/specs/profile-and-settings/spec.md) | My Card, settings, logout, delete account, legal docs |
| [admin-console](openspec/specs/admin-console/spec.md) | Admin login, mailing templates, restrictions, SQL viewer |
