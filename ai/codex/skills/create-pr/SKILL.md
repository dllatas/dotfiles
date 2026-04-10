---
name: create-pr
description: >
  Prepare and create a pull request by verifying the correct base branch,
  drafting a concise PR summary, and inferring a strong PR title from that
  summary. Use this skill whenever someone asks to create a PR, open a pull
  request, draft PR metadata, or sanity-check the branch a PR should target.
---

# create-pr

Create pull requests with an explicit target branch and reviewable metadata.

## Core Rules

- Never guess the PR base branch from habit alone. Verify it from repo conventions, remote defaults, or the user's explicit instruction.
- If the correct base branch is ambiguous, stop and resolve that before opening the PR.
- Draft the PR description summary first, then derive the PR title from that summary.
- Keep the PR title specific and outcome-oriented rather than repeating the branch name.

## Workflow

1. If the repository policy is to work in a git worktree, create or switch into that worktree before preparing the PR.
2. Identify the current branch and confirm it is the branch that should be proposed.
3. Verify the intended base branch explicitly using repository docs, git remote defaults, branch tracking info, or direct user guidance.
4. Check for merge conflicts by running `git merge-tree $(git merge-base HEAD <base>) HEAD <base>` or attempting a dry-run merge. If conflicts exist, resolve them automatically (see Conflict Resolution below) before continuing.
5. Review the diff against that base branch so the PR description reflects the actual change set.
6. Draft a short PR summary that explains the problem solved, the key changes, and any important reviewer context.
7. Infer the PR title from that summary, keeping it concise and aligned with the repository's conventions.
8. Create the PR with the verified base branch instead of relying on a default target.

## Base Branch Checks

- Prefer explicit evidence such as release workflow docs, repository guidance, or a configured upstream branch.
- Use the remote default branch only when it matches the repository's actual PR workflow.
- If the branch should target something other than the default branch, call that out clearly in the PR body.

## PR Description Shape

Use a compact structure like this:

```text
## Summary
- What changed
- Why it changed

## Testing
- What was verified
```

Add extra reviewer notes only when they materially help with rollout, migration, or risk.

## Title Guidance

- Write the summary first, then compress the main outcome into the title.
- Prefer the user-visible or reviewer-relevant outcome over implementation detail.
- Match the repository's style when it already uses a recognizable PR title pattern.

## Conflict Resolution

When merge conflicts are detected between the current branch and the base branch:

1. Fetch the latest base branch: `git fetch origin <base>`.
2. Rebase onto the base branch (`git rebase origin/<base>`) rather than merging, to keep history linear.
3. For each conflicting file, read both sides of the conflict and resolve it automatically:
   - Prefer the current branch's intent when it clearly implements the task at hand.
   - Prefer the base branch's version when the current branch only touches unrelated lines near the conflict.
   - When both sides make meaningful, non-overlapping changes, combine them so neither is lost.
4. After resolving all conflicts, stage the files and continue the rebase (`git rebase --continue`).
5. Only ask the user for guidance when the conflict is in a section where both sides make substantive, incompatible semantic changes and the correct resolution is genuinely ambiguous (e.g., conflicting business logic or API contracts). In that case, present the two versions clearly and ask for a decision before proceeding.

## Before Finishing

- Confirm the PR compares the current branch against the verified base branch.
- Check that the title matches the summary rather than contradicting it.
- Make sure the description reflects the current diff, not stale assumptions from earlier iterations.
