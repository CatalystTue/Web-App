# catalyst_flutter_app

A new Flutter project.

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
