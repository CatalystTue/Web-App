## Why

This brownfield Flutter web app had no OpenSpec source of truth. Reverse-engineered Kiro requirements already captured current production behavior; they need to live as OpenSpec capabilities so later changes can be deltas instead of rediscovering the product.

## What Changes

- Seed living specs from existing production behavior (not a redesign)
- Tag every reverse-engineered requirement and scenario `[PRE]` so they are not treated as new work
- Remove `.kiro/specs/` after the capabilities land under `openspec/specs/`
- No product, API, or UI behavior changes

## Capabilities

### New Capabilities
- `platform-and-session`: app shell, API client, tokens, routing, and auth gates
- `user-authentication`: splash, register, login, email verification
- `account-recovery`: recover account and reset password
- `onboarding`: profile init form and LLM description choice
- `matching-stack`: home card stack, likes, undo
- `profile-and-settings`: My Card, settings, logout, delete account, legal docs
- `admin-console`: admin login, mailing templates, restrictions, SQL viewer

### Modified Capabilities

## Impact

Documentation only. No application code, APIs, or runtime behavior change. Source of the requirements is `.kiro/specs/` (to be deleted after archive). On web, named routes are hash URLs (for example `/#/auth`).
