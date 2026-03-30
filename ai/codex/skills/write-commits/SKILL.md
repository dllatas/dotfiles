---
name: write-commits
description: >
  Plan and create git commits for completed changes using small logical units,
  atomic staging, and verbose messages that explain why the change exists. Use
  this skill whenever someone asks to write commits, split work into several
  commits, draft commit messages, clean up history before pushing, or prepare a
  branch for review.
---

# write-commits

Create commit history that is easy to review, rebase, and understand later.

## Core Rules

- Prefer several focused commits over one large commit when the work contains distinct logical units.
- Each commit must be atomic: stage only the files or hunks needed for that unit of change.
- Write commit messages that explain why the change exists and any important context, not only what changed.
- Prefer rebasing over merge commits when branch synchronization or history cleanup is needed.
- Use only the author identity already configured in the local git config for this repository.
- Never add AI-agent co-author trailers or override authorship with `--author`.

## Workflow

1. If the repository policy is to work in a git worktree, create or switch into that worktree before staging or committing.
2. Inspect the working tree with `git status --short` and review the diff before staging anything.
3. Split the changes into logical units. If a file mixes unrelated work, stage specific hunks instead of the whole file.
4. For each unit, verify the staged diff is coherent and self-contained with `git diff --cached`.
5. Commit each unit with a conventional-commit style subject when the repository uses that convention.
6. Add a commit body when the reason, constraint, migration note, or tradeoff would not be obvious from the subject alone.
7. If the branch must be synchronized before pushing, prefer `git fetch` plus rebase-based flows instead of merge commits.

## Commit Message Shape

Use this default structure:

```text
type(scope): short summary

Why this change is needed.

Important context, constraints, or follow-up notes when they help a reviewer.
```

Guidance:

- Keep the subject specific and readable in `git log --oneline`.
- Use the body to explain intent, user impact, cleanup rationale, or compatibility constraints.
- Do not add empty bodies just to satisfy the template.
- Do not mention AI assistance or add `Co-authored-by` trailers.

## Rebase Guidance

- Prefer rebasing local commits onto the updated upstream branch when history needs to be refreshed.
- Keep the commit series readable after the rebase; reorder or squash only when it improves logical clarity.
- Do not rewrite shared history unless the user clearly intends that outcome.

## Authorship Rules

- Respect `git config user.name` and `git config user.email` from the current repository scope.
- Do not pull credentials or author details from any other repository, global profile, or external source.
- If authorship looks misconfigured, stop and let the user fix local git config before committing.

## Before Finishing

- Confirm each commit leaves the tree in a sensible intermediate state.
- Check that the staged content matches the commit message.
- Leave unrelated or unfinished changes unstaged unless the user explicitly wants them included.
