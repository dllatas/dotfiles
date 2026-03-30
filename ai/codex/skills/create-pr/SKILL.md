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
4. Review the diff against that base branch so the PR description reflects the actual change set.
5. Draft a short PR summary that explains the problem solved, the key changes, and any important reviewer context.
6. Infer the PR title from that summary, keeping it concise and aligned with the repository's conventions.
7. Create the PR with the verified base branch instead of relying on a default target.

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

## Before Finishing

- Confirm the PR compares the current branch against the verified base branch.
- Check that the title matches the summary rather than contradicting it.
- Make sure the description reflects the current diff, not stale assumptions from earlier iterations.
