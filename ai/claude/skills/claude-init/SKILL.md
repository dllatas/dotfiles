---
name: claude-init
description: >
  Onboard any repository for use with Claude Code by analyzing its structure
  and generating a tailored .claude/ setup. Use this skill whenever someone
  asks to "set up Claude" for a project, "onboard a repo", "create a CLAUDE.md",
  "initialize Claude Code config", or mentions wanting Claude to understand
  their codebase. Also trigger when someone says "claude-init" or asks how to
  make Claude work well with their project.
disable-model-invocation: true
argument-hint: "[path-to-repo]"
---

# claude-init — Repository Onboarding for Claude Code

Analyze a repository and generate a complete `.claude/` setup tailored to
the project's stack, conventions, and workflows.

## What to Generate

1. **CLAUDE.md** — The main project guide
2. **AGENTS.md** — Sub-agent role definitions
3. **.claude/commands/** — Slash commands for common workflows
4. **.claude/settings.json** — Shared team permissions
5. **.gitignore entries** — Keep local-only state out of VCS
6. **MEMORY.md** *(optional)* — Agent-maintained discoveries file
7. **BACKLOG.md** *(optional)* — Lightweight task tracking

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
- `CLAUDE.md` / `AGENTS.md` — if they exist, we're augmenting, not replacing
- `.claude/` — check what already exists

### Git History Analysis

Run `git log --oneline -20` to detect:

- Commit message conventions (conventional commits? freeform?)
- Active contributors
- Recent areas of change

## Step 2: Draft CLAUDE.md

Structure the file following this template. Keep it under 200 lines.
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

## Step 3: Draft AGENTS.md

Define 2-4 sub-agent roles relevant to the project. Common patterns:

- **Reviewer Agent** — What to check during code review (project-specific
  invariants, test coverage expectations, style rules)
- **Explorer Agent** — How to navigate the codebase (entry points,
  central modules, large files to treat as reference data)
- **Deployment Agent** — Build/push/deploy steps with image naming, registry,
  and GitOps target paths

Only include roles that make sense for the project. A simple library
might only need Reviewer. A full-stack app with CI/CD might need all three.

## Step 4: Scaffold Slash Commands

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

## Step 5: Generate settings.json

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

## Step 6: Update .gitignore

Append these entries if not already present:

```
# claude code local state
.claude/settings.local.json
.claude/worktrees/
```

## Step 7: Optional Project Scaffolding

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

## Step 8: Present to User

After generating everything, present a summary:

1. List each file created and its purpose
2. Highlight anything that needs manual review (e.g., env vars you
   couldn't determine, unclear project conventions)
3. Ask if they want to adjust anything before committing

Do NOT auto-commit. Let the user review and decide when to commit.
The user might want to tweak the CLAUDE.md or adjust commands before
locking them in.

## Handling Existing Setups

If the repo already has a `.claude/` folder or `CLAUDE.md`:

- **Read what exists first** — don't overwrite blindly
- **Identify gaps** — what's missing compared to the full setup?
- **Propose additions** — "I see you have CLAUDE.md but no commands. Want me to add /build and /test?"
- **Merge, don't replace** — add new sections to existing files rather than rewriting from scratch

## Quality Checks

Before presenting to the user, verify:

- [ ] CLAUDE.md is under 200 lines
- [ ] All commands reference actual scripts/tools found in the project
- [ ] No placeholder text like "[TODO]" or "[fill in]" remains
- [ ] .gitignore entries don't duplicate existing ones
- [ ] Settings permissions match the project's actual toolchain
