# Daniel's Global Codex Preferences

These instructions are intended for the global Codex `AGENTS.md` layer so they apply consistently across projects.

## Languages & Stack

- Primary: Go for backend services, Node.js and TypeScript for backend and frontend, Python for GenAI and ML workflows
- Frontend: TypeScript with React, with Next.js App Router preferred when relevant
- Infra: Docker, k3s, and GitOps-style deployments

## Code Style

- TypeScript: strict mode, `@/` path aliases when the project uses them, and zod for validation
- Go: standard library first, minimal dependencies, `go fmt`, and `golangci-lint`
- Python: type hints, ruff, and minimal dependencies
- Node.js imports: use the `node:` prefix for built-in modules
- Prefer named exports; use default exports only where the framework expects them, such as React page and layout components

## Naming

- Files: kebab-case
- Components: PascalCase
- Functions and variables: camelCase
- Database tables and columns: snake_case
- Environment variables: SCREAMING_SNAKE_CASE

## Workflow

- Prefer reading the existing docs and project guidance before changing code
- Keep changes aligned with the repo's actual tooling and conventions; do not invent commands or workflows
- In git repositories, create and use a git worktree for the task instead of editing in the current checkout unless the user explicitly asks otherwise
- If a worktree cannot be created safely, stop and explain the blocker before working in the current checkout
- Update project `AGENTS.md` files when repeated repo-specific guidance should persist

## Commits & PRs

- Use conventional commits with scope when making commits
- Prefer several focused commits over one broad commit
- Commit messages should explain why the change exists, not only what changed
- PR descriptions should explain the problem being solved

## Testing

- Write tests for non-trivial logic
- Run the relevant test suite before treating the work as done
- Validate fallback and degraded behavior when dependencies are optional

## Error Handling

- Prefer graceful degradation over hard failures when optional services are unavailable
- External integrations should have fallback paths where practical
- Worker and pipeline flows should tolerate per-item failures and report them clearly

## Dependencies

- Prefer existing helpers and standard library functionality before adding abstractions
- Minimize new dependencies and keep solutions explicit

## Agent Behavior

- Think before writing: read relevant files before producing code rather than starting from assumptions
- Keep output concise with no flattering preambles or closing fluff
- Prefer targeted edits over full file rewrites unless the scope genuinely requires rewriting
- Read each file once per task unless it was modified since last read
- Favor the simplest direct fix and resist over-engineering
- Use available CLI tools such as `gh` for GitHub operations and installed linters for checks
- Re-read the project AGENTS.md at the start of every new task to refresh context
- When user instructions conflict with these defaults, follow the user
