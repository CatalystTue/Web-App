# catalyst_flutter_app

Flutter web frontend for Catalyst. Members sign in, complete a profile card, and browse a stack of other users. Admins have a separate console.

Current behavior is specified in [`openspec/specs/`](openspec/specs/). `[PRE]` on a requirement means it was reverse-engineered from this codebase, not new work.

## Getting Started

The API URL is set at compile time via `--dart-define=API_BASE_URL=...` (`lib/Core/Constants/config.dart`). If omitted, it defaults to `https://server.catalyst-app.org/api/v1`.

Run locally against a local backend (start the backend first, typically `http://127.0.0.1:8000`):

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

Build the web app (production API unless you pass `--dart-define`):

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
| `/admin` | Admin login |
| `/admin-welcome` | Admin area |

## Specs

| Capability | Covers |
| --- | --- |
| [platform-and-session](openspec/specs/platform-and-session/spec.md) | App shell, API client, tokens, routing, auth gates |
| [user-authentication](openspec/specs/user-authentication/spec.md) | Splash, register, login, email verification |
| [account-recovery](openspec/specs/account-recovery/spec.md) | Recover account and reset password |
| [onboarding](openspec/specs/onboarding/spec.md) | Profile init form and LLM description choice |
| [matching-stack](openspec/specs/matching-stack/spec.md) | Home card stack, likes, undo |
| [profile-and-settings](openspec/specs/profile-and-settings/spec.md) | My Card, settings, logout, delete account, legal docs |
| [admin-console](openspec/specs/admin-console/spec.md) | Admin login, mailing templates, restrictions, SQL viewer |
