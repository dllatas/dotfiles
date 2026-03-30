# Daniel's Global Preferences

## Languages & Stack
- Primary: Go (backend services), Node.js/TypeScript (backend + frontend), Python (GenAI/ML)
- Frontend: TypeScript with React (Next.js App Router preferred)
- Infra: Docker, k3s, GitOps deployments via Harbor registry

## Code Style
- TypeScript: strict mode always, `@/` path aliases, zod for validation
- Go: standard library first, minimal dependencies, `go fmt` + `golangci-lint`
- Python: type hints, ruff for linting, keep it minimal - only used for GenAI pipelines
- Node imports: use `node:` prefix for built-in modules (e.g., `import crypto from "node:crypto"`)
- Prefer named exports; default exports only for React page/layout components

## Naming
- Files: kebab-case (`content-filter.ts`, `release-table.tsx`)
- Components: PascalCase (`FrontSheet`, `TagEditor`)
- Functions/variables: camelCase
- DB tables/columns: snake_case
- Environment variables: SCREAMING_SNAKE_CASE

## Commit Style
- Use conventional commits with scope: `feat(ui):`, `fix(docker):`, `refactor(worker):`
- Atomic commits: group related changes, prefer several focused commits over one large one
- Be verbose in messages: explain *why*, not just *what*
- Create commits during development whenever a logical unit is complete

## PR & Workflow
- Always create a local preview after finishing an iteration
- Create a PR for changes with a clear description
- PRs should reference the problem being solved, not just list files changed
- In git repositories, create and use a git worktree for the task instead of editing in the current checkout unless the user explicitly asks otherwise
- If a worktree cannot be created safely, stop and explain the blocker before working in the current checkout

## Testing
- Write tests for non-trivial logic; colocate test files (`*.test.ts` next to source)
- Run the full test suite before considering work done
- Validate fallback/degraded behavior when services are optional

## Error Handling
- Services with optional dependencies must degrade gracefully, never hard-fail
- External API calls need fallback paths
- Worker/pipeline processes: continue on per-item failures, aggregate and report errors

## Dependencies
- Prefer existing helpers before introducing new abstractions
- Minimize new dependencies; check if the standard library or existing deps cover the need
