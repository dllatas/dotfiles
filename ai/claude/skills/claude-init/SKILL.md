---
name: claude-init
description: >
  Onboard any repository for use with Claude Code by analyzing its structure
  and generating portable AGENTS.md-first guidance plus a tailored .claude/
  setup. Use this skill whenever someone asks to "set up Claude" for a project,
  "onboard a repo", "create a CLAUDE.md", "initialize Claude Code config", or
  mentions wanting Claude to understand their codebase. Also trigger when
  someone says "claude-init" or asks how to make Claude work well with their
  project.
disable-model-invocation: true
argument-hint: "[path-to-repo]"
---

# claude-init — Repository Onboarding for Claude Code

Analyze a repository and generate portable agent guidance plus a `.claude/`
setup tailored to the project's stack, conventions, and workflows.

## Portable Guidance Policy

Use one source of truth for repo guidance:

- `AGENTS.md` is canonical root guidance for all coding agents.
- `CLAUDE.md` is a symlink to `AGENTS.md`.
- Never write Claude subagent definitions into root `AGENTS.md`.
- Claude subagents, when useful, live as separate files in `.claude/agents/`.
- Update existing guidance in place. Do not overwrite or replace a regular
  `AGENTS.md` or `CLAUDE.md` without first reading and preserving its content.

Existing-file handling:

- If only `AGENTS.md` exists: update it, then create `CLAUDE.md -> AGENTS.md`.
- If only `CLAUDE.md` exists: copy/merge its content into new `AGENTS.md`, then
  replace `CLAUDE.md` with a symlink to `AGENTS.md` only after preserving the
  original content.
- If both exist and one is already a symlink to the other: update canonical
  `AGENTS.md`.
- If both exist as regular files: read both, merge useful content into
  `AGENTS.md`, and ask before replacing `CLAUDE.md` with a symlink if there is
  any conflict or uncertainty.

Repair flow when both root files already exist as regular files:

1. Read `AGENTS.md` and `CLAUDE.md` before editing either file.
2. Treat `AGENTS.md` as destination and preserve all non-duplicated guidance
   from both files.
3. Move Claude-only material out of root guidance:
   - slash-command workflow notes → `.claude/commands/`
   - subagent definitions → `.claude/agents/`
   - Claude permission/settings notes → `.claude/settings.json`
4. Remove duplicated or product-specific wording from `AGENTS.md` after the
   reusable guidance is merged.
5. If the merge is clear and lossless, replace root `CLAUDE.md` with a relative
   symlink using `ln -sf AGENTS.md CLAUDE.md`.
6. If the two files conflict on commands, architecture, safety rules, or commit
   workflow, stop and ask which source should win before replacing anything.
7. In the final summary, explicitly list what was merged, moved, and symlinked.

## What to Generate

1. **AGENTS.md** — Canonical portable project guide
2. **CLAUDE.md** — Symlink to `AGENTS.md`
3. **.claude/agents/** *(optional)* — Claude subagent definitions
4. **.claude/commands/** — Slash commands for common workflows
5. **.claude/settings.json** — Shared team permissions
6. **.gitignore entries** — Keep local-only state out of VCS
7. **MEMORY.md** *(optional)* — Agent-maintained discoveries file
8. **BACKLOG.md** *(optional)* — Lightweight task tracking

## Step 1: Discover the Project

Scan the repo root and key directories to understand the project. Gather
this information before writing anything:

### Language & Framework Detection

Check for these files (in priority order) to identify the stack:

| File                   | Stack Signal                              |
|------------------------|-------------------------------------------|
| `package.json`         | Node.js/TypeScript — read `scripts`, `dependencies`, `devDependencies` |
| `go.mod`               | Go — read module path and dependencies    |
| `pyproject.toml`       | Python — read build system, dependencies  |
| `requirements.txt`     | Python (pip-based)                        |
| `Cargo.toml`           | Rust                                      |
| `pom.xml` / `build.gradle` | Java/Kotlin                           |
| `Gemfile`              | Ruby                                      |
| `mix.exs`              | Elixir                                    |
| `composer.json`        | PHP                                       |
| `Makefile`             | Build automation (language-agnostic)      |

### Build/Test/Lint Commands

Extract the actual commands the project uses. Prefer project-defined
commands over guesses:

- **Node.js**: read `scripts` from `package.json`
- **Go**: look for `Makefile` targets, otherwise `go build`, `go test`
- **Python**: check `pyproject.toml` for test runners (pytest, ruff, mypy)
- **Rust**: `cargo build`, `cargo test`, `cargo clippy`

### Project Structure

Map the key directories. Run `find . -maxdepth 2 -type d` (excluding
`node_modules`, `.git`, `vendor`, `dist`, `build`, `.next`) to get the
layout. Identify:

- Where source code lives (`src/`, `pkg/`, `internal/`, `lib/`, `app/`)
- Where tests live (colocated? separate `tests/` dir?)
- Config files (`.env.example`, `docker-compose.yml`, etc.)
- CI/CD setup (`.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`)
- Infrastructure (Dockerfile, k8s manifests, terraform)

### Existing Documentation

Check for existing guidance files that should be incorporated or
superseded:

- `README.md` — extract purpose, setup instructions
- `CONTRIBUTING.md` — extract coding standards
- `AGENTS.md` / `CLAUDE.md` — determine canonical guidance and symlink state
- `.claude/` — check what already exists

### Non-Obvious Patterns & Tribal Knowledge

After reading the code and docs, do a targeted scan for knowledge that is not
surfaced anywhere obvious. For each module or major subsystem, ask:

1. What are the common modification patterns a developer would need to know?
2. What non-obvious patterns cause build or runtime failures?
3. What cross-module dependencies are implicit rather than declared?
4. What tribal knowledge is buried in code comments, TODOs, or workaround blocks?

Focus especially on questions 2 and 4 — these are where undocumented pitfalls
live (e.g. hidden field naming conventions between pipeline stages, implicit
ordering requirements, env vars that silently change behavior). Surface these
in the AGENTS.md "Non-Obvious Patterns" section rather than leaving them in
comments no one reads.

### Branch Freshness

Before analyzing the repo, ensure you are working with up-to-date code:

- Ask the user whether the current local branch is up-to-date with its remote.
- If the user is unsure or confirms it may be stale, run `git fetch origin` and
  compare `git rev-parse HEAD` with `git rev-parse @{u}` to check for upstream
  changes. If behind, inform the user and ask whether to pull before continuing.
- This prevents generating guidance based on outdated code, which leads to
  incorrect commands, stale repo maps, or missing conventions.

### Git History Analysis

Run `git log --oneline -20` to detect:

- Commit message conventions (conventional commits? freeform?)
- Active contributors
- Recent areas of change

## Step 2: Draft AGENTS.md

Structure the canonical guidance file following this template. Keep it under
200 lines.
Replace or omit sections that don't apply.

```markdown
# [Project Name] Agent Guide

## Purpose
[1-3 sentences: what this project does, who it serves]

## Stack
[Bullet list of language, framework, key libraries with versions]

## Repo Map
[Bullet list: key directories and what they contain]

## Commands
[Bullet list: the actual build/test/lint/dev commands from discovery]

## Environment
[Bullet list: env vars from .env.example or docs, noting which are optional]

## Runtime Behavior You Must Preserve
[Invariants: things that must not break — graceful degradation, API contracts, etc.
 Only include this if there are genuine invariants worth calling out.]

## API Surface
[If applicable: list routes/endpoints/exported functions]

## Editing Rules
[Coding standards extracted from the project's conventions:
 - Import style, naming conventions
 - Path aliases
 - Validation patterns
 - Schema change procedures]

## Testing Expectations
[What to run, when, and how to validate changes]

## Known High-Risk Areas
[Files or modules where accidental changes cause outsized breakage]

## Non-Obvious Patterns
[Tribal knowledge that is not documented anywhere else:
 - Implicit ordering requirements
 - Hidden naming conventions between subsystems
 - Env vars or flags that silently alter behavior
 - Workarounds and the bugs they paper over]

## Commit Style
[Extracted from git history analysis]
```

### Writing Principles

- **Be specific, not generic.** "Run `npm test`" is better than "run the tests."
  Use the actual commands and paths from the project.
- **Focus on what an agent needs to know**, not what a human would already
  know from the README. The agent needs: how to build, what not to break,
  where things live, and what the conventions are.
- **Include the "why" for non-obvious rules.** If there's a reason behind
  a convention, explain it briefly so the agent can apply judgment in
  edge cases.
- **Token budget:** this file loads into every session — every unnecessary line
  costs attention. Drop articles in list items; use `→` for causal chains; no prose in bullets.
- **Lost in the middle:** LLM attention drops sharply for content in the middle of long documents.
  Put critical constraints (commands, high-risk areas) at the top or bottom — never only in the middle.

## Step 3: Link CLAUDE.md to AGENTS.md

After `AGENTS.md` is created or updated, make root `CLAUDE.md` a symlink to it:

```bash
ln -sf AGENTS.md CLAUDE.md
```

Do not use an absolute symlink. Keep the repo portable when cloned elsewhere.

If `CLAUDE.md` is a regular file, preserve its content first:

- if its content is already represented in `AGENTS.md`, replace it with the
  symlink
- if it contains unique guidance, merge that guidance into `AGENTS.md` before
  replacing it
- if both files conflict, ask the user before replacing anything

## Step 4: Draft Claude Subagents Only When Useful

If the project benefits from Claude subagents, create 2-4 files under
`.claude/agents/`. Do not create or overwrite root `AGENTS.md` for subagent
roles.

Common patterns:

- **Reviewer Agent** — What to check during code review (project-specific
  invariants, test coverage expectations, style rules)
- **Explorer Agent** — How to navigate the codebase (entry points,
  central modules, large files to treat as reference data)
- **Deployment Agent** — Build/push/deploy steps with image naming, registry,
  and GitOps target paths

Only include roles that make sense for the project. A simple library might not
need any subagents.

## Step 5: Scaffold Slash Commands

Create `.claude/commands/` with markdown files for common workflows.
Each command should be a focused, opinionated sequence of steps.

### Which Commands to Create

Detect from the project's tooling:

| If you find...              | Create command      | Purpose                        |
|-----------------------------|--------------------|---------------------------------|
| `npm test` / `go test` / `pytest` | `/test`      | Run full suite or focused tests |
| `npm run build` / `go build` / `cargo build` | `/build` | Lint → test → build pipeline |
| `Dockerfile`                | `/deploy`          | Build image, push, output tag   |
| `drizzle` / `prisma` / `sqlx` / migration dir | `/db` | Database operations       |
| `docker-compose.yml`       | `/dev-up`          | Start local dev environment     |
| Worker/queue scripts        | `/worker`          | Run background job processor    |

### Command File Format

```markdown
# [Command Name]

[1-sentence description of what this does]

Arguments: $ARGUMENTS (describe expected args or "none")

## Steps

1. [Concrete step with actual command]
2. [Next step]
3. [Report results]
```

## Step 6: Generate settings.json

Create `.claude/settings.json` with pre-approved safe operations:

```json
{
  "permissions": {
    "allow": [
      "Bash(git log:*)",
      "Bash(git diff:*)",
      "Bash(git status:*)",
      "Bash(git branch:*)"
    ]
  }
}
```

Add project-specific permissions based on detected tools:

- Node.js: add `Bash(npm test:*)`, `Bash(npm run lint:*)`, `Bash(npm run build:*)`
- Go: add `Bash(go test:*)`, `Bash(go build:*)`, `Bash(go vet:*)`
- Python: add `Bash(pytest:*)`, `Bash(ruff:*)`, `Bash(mypy:*)`
- Rust: add `Bash(cargo test:*)`, `Bash(cargo build:*)`, `Bash(cargo clippy:*)`

Note: create `settings.json` (team-shared, committed) not
`settings.local.json` (personal, gitignored). If there's already a
`settings.local.json`, leave it alone.

## Step 7: Update .gitignore

Append these entries if not already present:

```
# claude code local state
.claude/settings.local.json
.claude/worktrees/
```

## Step 8: Optional Project Scaffolding

Create these only when they add clear value for this specific project. Ask the
user if unsure — don't generate them by default.

### MEMORY.md

Create when the repo has non-obvious pitfalls or architecture details worth
preserving across sessions. Keep it under 100 lines and focus on things that
are hard to rediscover from the code alone:

- Architecture overview (how the major pieces connect)
- Build/test command gotchas (env vars required, order-dependent steps)
- Non-obvious pitfalls discovered during onboarding
- Test infrastructure quirks (seeds, fixtures, external dependencies)

Do not duplicate the README. The audience is an agent resuming work, not a
new human contributor. Update it during work whenever something non-obvious
is discovered.

```markdown
# Project Memory

## Architecture
[How the major pieces connect — not what the README says, but what a dev
 needs to know to not break things]

## Build & Test Gotchas
[Order-dependent steps, required env vars, known flakiness]

## Non-obvious Pitfalls
[Things that look safe but aren't; edge cases that have burned people before]

## Test Infrastructure
[Seeds, fixtures, external service dependencies, snapshot update commands]
```

### BACKLOG.md

Create when the project has no external task tracker (Linear, GitHub Issues,
Jira) or when the user wants agent-managed task lists. Use three sections:

```markdown
# Backlog

## Todo
- [ ] item

## In Progress
- [ ] item currently being worked on

## Completed
- [x] item that is done
```

Agent workflow: check off items as each unit of work completes, and include
the checkbox update in the same commit as the change.

## Step 9: Present to User

After generating everything, present a summary:

1. List each file created and its purpose
2. Highlight anything that needs manual review (e.g., env vars you
   couldn't determine, unclear project conventions)
3. Ask if they want to adjust anything before committing

Do NOT auto-commit. Let the user review and decide when to commit.
The user might want to tweak `AGENTS.md` or adjust commands before
locking them in.

## Handling Existing Setups

If the repo already has a `.claude/` folder, `AGENTS.md`, or `CLAUDE.md`:

- **Read what exists first** — don't overwrite blindly
- **Identify gaps** — what's missing compared to the full setup?
- **Propose additions** — "I see you have AGENTS.md but no commands. Want me to add /build and /test?"
- **Merge, don't replace** — add new sections to existing files rather than rewriting from scratch
- **Keep one guidance source** — canonicalize into `AGENTS.md`; make `CLAUDE.md` a symlink

## Quality Checks

Before presenting to the user, verify:

- [ ] AGENTS.md is under 200 lines
- [ ] CLAUDE.md is a relative symlink to AGENTS.md, unless user explicitly declined
- [ ] All commands reference actual scripts/tools found in the project
- [ ] No placeholder text like "[TODO]" or "[fill in]" remains
- [ ] .gitignore entries don't duplicate existing ones
- [ ] Settings permissions match the project's actual toolchain

**Critic pass:** re-read the generated AGENTS.md against the actual code and
confirm each claim. A doc that names a file, flag, or command that does not
exist is worse than no doc. Verify all referenced paths exist and all commands
run from the documented location.
