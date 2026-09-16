---
name: openspec-flush
description: >-
  Land complete open changes via bulk-archive, then draft a commit.
  Commit only after the user approves. Use when flushing open changes
  or /opsx-flush. Not a live-docs audit.
allowed-tools: Bash(openspec:*), Bash(git:*)
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: catalyst
  version: "1.0"
---

Land the open-change queue. This repo has no live `openspec/design/` or
`openspec/layout.md`. Do not invent an audit workflow.

**Store selection:** If the user names a store (a store is a standalone OpenSpec repo registered on this machine) or the work lives in one, run `openspec store list --json` to discover registered store ids, then pass `--store <id>` on the commands that read or write specs and changes (`new change`, `status`, `instructions`, `list`, `show`, `validate`, `archive`, `doctor`, `context`, `schemas`, `view`). Once selected, treat `--store <id>` as sticky for the rest of the workflow. Every unscoped example of those commands below is shorthand: before running it, append the flag. For example, run `openspec status --change "<name>" --json --store "<id>"`, not the unscoped form shown below. Other commands do not take the flag. Hints printed by commands already carry the flag; keep it on follow-ups. Without a store, commands act on the nearest local `openspec/` root.

Announce: `Flushing open OpenSpec changes`.

## 1. Queue

`openspec list --json`. None → `No open changes.` Stop.

Ready as `openspec-bulk-archive-change` defines it (do not restate). Any
not Ready → list name and why, then stop. Do not follow
bulk-archive-change.

## 2. Land

Follow `.cursor/skills/openspec-bulk-archive-change/SKILL.md`.
Auto-select all. Skip its pick-which prompt. Do not archive a ready-only
subset: if step 1 stopped, this step does not run. Caller has not run
`openspec-sync-specs` (bulk-archive-change does).

Stop on a merge error. Do not move `changeRoot` until that change's
spec sync finished.

## 3. Commit draft

Show `git status` and a message. Do not commit.
Subject: short why-line. No file lists. Sections from the diff (code,
specs, archive, tests, README). Group by change when clearer.
Why, not file lists. No secrets.

## 4. Commit on approval

On explicit approval only: stage relevant files and `git commit` with
the drafted message. No `--no-verify`. No amend unless the user asked.
Then `git status`.
