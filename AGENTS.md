# Agent notes

This repo uses **OpenSpec** (`openspec/`) as the contract. `README.md` is the operator guide, not a second spec.

## Living docs

- Behavior: `openspec/specs/<capability>/spec.md` — SHALL/MUST + `#### Scenario:`
- Config and archive hooks: `openspec/config.yaml`

There is no living `openspec/design/` or `openspec/layout.md` in this repo. Do not invent SHALL/MUST or a Decision to hold a note. Do not treat `openspec/changes/` (active or archived) as the live contract. `[PRE]` on a requirement means it was reverse-engineered from this codebase, not new work.

## Changes

Behavior work goes through `openspec/changes/<kebab-name>/`. Default schema is `spec-driven`:

1. **proposal** — why, what, which capabilities
2. **specs** — delta Requirements (`ADDED` / `MODIFIED` / `REMOVED`)
3. **design** — how (optional; skip when the instruction marks it optional)
4. **tasks** — `- [ ]` checkboxes with how to verify
5. **apply** — implement tasks
6. **archive** — stock spec sync, then follow `openspec/config.yaml` archive guidance (update `README.md` when Pages, Getting Started, or the Specs table changed)

CLI: `openspec new change`, `status`, `instructions`, `list`, `validate`, `archive`. Follow the matching skill; do not invent a workflow.

Project skills — read the committed files; do not require a local tool copy:

- `.cursor/skills/openspec-new-change/SKILL.md`
- `.cursor/skills/openspec-propose/SKILL.md`
- `.cursor/skills/openspec-ff-change/SKILL.md`
- `.cursor/skills/openspec-continue-change/SKILL.md`
- `.cursor/skills/openspec-update-change/SKILL.md`
- `.cursor/skills/openspec-apply-change/SKILL.md`
- `.cursor/skills/openspec-verify-change/SKILL.md`
- `.cursor/skills/openspec-sync-specs/SKILL.md`
- `.cursor/skills/openspec-explore/SKILL.md`
- `.cursor/skills/openspec-archive-change/SKILL.md`
- `.cursor/skills/openspec-bulk-archive-change/SKILL.md`

If a skill is absent, use the CLI (`openspec new change`, `openspec instructions`, `openspec archive`). Explore is think-only: do not implement.

## Parking work

Follow `.cursor/rules/openspec-todo-hashtags.mdc`. Write `#TODO:` / `#FIXME:` / `#ALT:` / `#BUG:` / `#HACK:` / `#XXX:` on the live spec — not an Open Question. Implementation is `- [ ]` in `tasks.md`. Unsure or missing file → ask once.
