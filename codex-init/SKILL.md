---
name: codex-init
description: >
  Onboard any repository for use with OpenAI Codex by analyzing its structure
  and generating a tailored AGENTS.md setup, optional project-scoped
  .codex/config.toml, and repo-local skill scaffolding when useful. Use this
  skill whenever someone asks to "set up Codex" for a project, "onboard a repo"
  for Codex, "create AGENTS.md", "initialize Codex config", "add Codex project
  guidance", or explicitly mentions "codex-init".
---

# codex-init

Analyze a repository and generate the Codex project guidance it actually needs.

Keep the output concrete and minimal. Do not create config layers or repo-local
skills unless they materially help this specific repository.

## What to Generate

Possible outputs, in priority order:

1. `AGENTS.md` in the repo root
2. Nested `AGENTS.md` files only where a subdirectory genuinely needs different rules
3. `.codex/config.toml` only when the repo needs project-scoped Codex overrides
4. `.agents/skills/<skill-name>/` only when the repo has a repeatable workflow that deserves a reusable skill

## Step 1: Discover the Project

Before writing anything, inspect the repo and extract the real workflows.

### Detect the stack

Check for these files first:

- `package.json`
- `go.mod`
- `pyproject.toml`
- `requirements.txt`
- `Cargo.toml`
- `pom.xml`
- `build.gradle`
- `Gemfile`
- `mix.exs`
- `composer.json`
- `Makefile`

### Extract actual commands

Prefer project-defined commands over guesses:

- Node.js: read `scripts` from `package.json`
- Go: use `Makefile` targets if present, otherwise `go build` and `go test`
- Python: inspect `pyproject.toml` and existing docs for `pytest`, `ruff`, `mypy`, or other tooling
- Rust: `cargo build`, `cargo test`, `cargo clippy`

### Map the repo

List the key directories and identify:

- Source locations such as `src/`, `pkg/`, `internal/`, `lib/`, `app/`
- Test locations
- Config and environment files
- CI or automation files
- Docker, infrastructure, or deployment assets

### Read existing guidance

Check for:

- `README.md`
- `CONTRIBUTING.md`
- `AGENTS.md`
- `.codex/config.toml`
- `.agents/skills/`
- Any existing Claude or agent-specific guidance that should be translated rather than replaced

### Review recent git history

Run `git log --oneline -20` to detect commit conventions and recent areas of change.

## Step 2: Draft the Repo AGENTS.md

Create or update a root `AGENTS.md` that helps Codex work effectively in this repository.

Keep it specific, short, and operational. Good sections usually include:

- Purpose
- Repo map
- Commands
- Editing rules
- Testing expectations
- High-risk areas
- Commit style

Prefer actual commands and paths. Avoid generic advice.

## Step 3: Decide Whether Nested AGENTS.md Files Are Needed

Add nested `AGENTS.md` files only when a subtree has different rules, such as:

- a frontend folder with different commands and conventions
- an infrastructure folder with deployment-specific safeguards
- generated-code areas that should not be hand-edited

If the root file is enough, stop there.

## Step 4: Decide Whether .codex/config.toml Is Needed

Create `.codex/config.toml` only when the repo benefits from committed Codex overrides, for example:

- project-specific sandbox or approval behavior
- project-specific MCP server settings
- a custom `project_root_markers` setup
- a repo-specific `model_instructions_file`

Do not create `.codex/config.toml` just to restate defaults.

If you create it, keep it minimal and repo-specific.

## Step 5: Decide Whether Repo-Local Skills Are Needed

Create `.agents/skills/` only when the repository has a repeatable workflow that would otherwise be rewritten repeatedly, such as:

- release automation
- deployment runbooks
- database migration routines
- docs generation tied to repo-specific tooling

If you create a skill:

- keep `SKILL.md` lean
- add `agents/openai.yaml` metadata when useful
- prefer references or scripts over bloated inline instructions

## Step 6: Respect Existing Setup

When a repo already has Codex setup:

- read it first
- identify gaps
- merge instead of replacing
- avoid deleting working project guidance unless the user asked for a rewrite

When a repo has Claude-specific setup:

- reuse the useful project analysis
- translate product-specific pieces into Codex equivalents
- do not assume Claude slash commands or settings files map directly to Codex

## Step 7: Update Ignore Rules Only When Needed

Only touch `.gitignore` if you create local-only Codex files that should not be committed.

Do not add ignore rules for committed team files such as `AGENTS.md`, `.codex/config.toml`, or repo-local skills.

## Step 8: Present the Result

After generating the setup:

1. List each file created or updated and why
2. Call out any unclear conventions or missing information
3. Highlight anything that should be reviewed before committing

Do not auto-commit.

## Quality Checks

Before finishing, verify:

- `AGENTS.md` reflects the actual repo commands and structure
- nested `AGENTS.md` files exist only where needed
- `.codex/config.toml` contains only repo-specific overrides
- any repo-local skill has a clear trigger and compact instructions
- no placeholder text remains
