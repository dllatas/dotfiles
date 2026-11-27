---
name: habito-cli
description: >
  Use the `habito` CLI to read or change Daniel's Habito data on the staging
  server (habits, tracking, journals, moods, todos, routines, goals, insights,
  collections, tags, profile, snapshot). Use whenever the user asks to check,
  log, track, add, list, or update anything in Habito, or to exercise the
  staging API from the terminal.
---

# habito-cli

`habito` binary on PATH (`~/.local/bin/habito`) → Go CLI from `habito/backend/cmd/client`. Defaults already target staging: API `https://habito-api-staging.harokilabs.com`, Hydra `https://hydrav2.harokilabs.com`, client `habito-staging-cli`. No flags needed.

## Auth
- Token cache: `~/Library/Application Support/habito/oidc-token.json` (shared by every session/agent)
- Check: `habito auth-status` → `expires_at`, `has_refresh`
- Access token auto-refreshes via refresh token on each call
- `invalid_grant` / "refresh token expired" / "run `habito login` first" → run `habito login` in background, show user the verification URL + code, wait for approval. Never try to approve it yourself.
- Omit `user_id` args → commands act as the logged-in OIDC user. Don't pass explicit user IDs against staging.

## Sandbox
- Sandboxed shells fail TLS (`x509: OSStatus -26276`, keychain blocked) → run `habito` calls unsandboxed
- Rebuild after backend CLI changes: `cd ~/code/habito/backend && go build -o ~/.local/bin/habito ./cmd/client` (unsandboxed; needs Go module cache)

## Usage
- Discover: `habito --help`, `habito <cmd> --help`, `habito <cmd> <sub> --help` — check help before guessing arg shapes
- Overview of everything: `habito snapshot` (JSON; pipe through `jq`)
- Read: `habits`, `events`, `journals`, `todos`, `insights`, `counters`, `ratios`, `routine`, `goal`, `collection`, `tag`, `profile`
- Write: `habit`, `track`, `journal`, `journal-moods`, `todo`, `todo-status`, `todo-update`, `habit-update`, plus subcommands of `routine`/`goal`/`collection`/`tag`/`profile`

## Rules
- Staging holds real personal data → confirm before writes that delete or overwrite (`insight-rm`, tag/collection removals, bulk updates); creates/tracking the user asked for are fine
- Journals + moods are personal → summarize, don't dump full entries unless asked
- Moods: use canonical moods (`/v1/moods`); invalid mood → check list, don't invent
- Local backend instead: `habito --url localhost:3010 ...`
