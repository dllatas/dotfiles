---
name: update-docs
description: >
  Scan the codebase after a change, identify the docs and READMEs affected by
  the real behavior, update the ones that should stay in sync, and explicitly
  tell the human when you find stale documentation evidence. Use this whenever
  code, config, commands, workflows, install steps, or user-facing behavior
  changes and the docs may need to move with it.
---

# update-docs

Keep docs aligned with the code that actually exists.

## Core Rules

- Scan the relevant code, config, and task wiring before editing docs. Do not patch documentation from assumptions.
- Prefer updating the closest relevant docs first: feature docs, setup notes, role docs, and top-level README sections that describe the changed behavior.
- If you find concrete evidence that a doc is stale, explicitly tell the human with file references and a short explanation, even if you also fix it.
- Keep documentation faithful to the real install and runtime flow. Do not describe automation, commands, or behavior that the repository does not actually implement.
- Preserve repository terminology and command examples unless the code change requires updating them.

## Workflow

1. Inspect the changed code, config, scripts, and automation that define the real behavior.
2. Search for docs, READMEs, agent guides, comments, and examples that mention that behavior.
3. Compare documentation claims against the current implementation and note any stale or contradictory statements.
4. Update the docs that should remain authoritative for that behavior.
5. If some stale documentation is outside the requested scope or cannot be safely corrected yet, call it out clearly to the human instead of silently leaving it behind.
6. Before finishing, verify that referenced paths, commands, and filenames still exist.

## What To Update

- Top-level and package-level `README.md` files
- Setup and install docs
- Agent guidance files such as `AGENTS.md` and `CLAUDE.md` when behavior or policy changed
- Automation docs that describe roles, tasks, scripts, or generated files
- Inline examples and command snippets that would mislead a future reader if left unchanged

## Human Ping Rule

When you find evidence of stale docs, say so directly. Use a compact shape like:

```text
Stale docs found:
- path/to/file.md: line or section
  Why it is stale relative to the current code/config
```

Do this even when you also fix the issue, so the human understands why the documentation changed.

## Before Finishing

- Confirm the updated docs match the current code and automation.
- Check that commands are runnable from the documented location when the repo provides them.
- Mention any remaining documentation gaps or unresolved ambiguity.
