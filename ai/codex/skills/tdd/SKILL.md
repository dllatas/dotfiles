---
name: tdd
description: >
  Implement a non-trivial behavior change using a pragmatic test-driven
  development loop: specify concrete behavior, encode one executable scenario,
  fulfill that scenario with minimal code, and refactor only after tests are
  green. Use when adding or changing application, automation, or workflow logic
  that should be covered by tests or equivalent validation.
---

# tdd

Drive non-trivial behavior changes through executable specifications.

## Core Loop

Follow specify-encode-fulfill:

1. Specify the behavior as concrete scenarios.
2. Encode one scenario as an automated test or equivalent validation.
3. Run the targeted test and confirm it fails for the expected reason.
4. Fulfill the scenario with the smallest meaningful code change.
5. Run the targeted test until it passes.
6. Repeat for the remaining scenarios.
7. Refactor only after the behavior is covered and green.

## Specification Rules

- Restate the requested behavior in scenario form before writing tests.
- Prefer scenarios shaped like: `under scenario A, X happens; under scenario B, Y happens`.
- Avoid vague assertions such as `works correctly`, `handles input`, or `returns expected result`.
- Name the expected behavior directly in the test.

Good:

```text
when token refresh succeeds, cached credentials are replaced
when token refresh fails, existing credentials remain available and the error is reported
```

Bad:

```text
token refresh works correctly
```

## Test Translation

Use the project's actual test framework and conventions.

- Go: use existing `*_test.go` patterns and standard `testing` first.
- TypeScript: use the configured test runner and colocated test style when present.
- Python: use the existing pytest layout and type-aware helpers when present.
- Frontend: test behavior users depend on instead of implementation details.
- Infra and automation: use script tests, rendered manifests, syntax checks, or dry-runs when unit tests do not fit.

Write one focused test at a time. Prefer observable behavior over internal mechanics.

## Implementation Rules

- Write only enough code to satisfy the current failing test.
- Do not add speculative options, abstractions, fallbacks, or defensive branches unless the current scenario requires them.
- Prefer existing helpers, patterns, and project conventions.
- Keep refactors separate from behavior changes when practical.
- If a refactor is needed before the test can be written cleanly, pause and explain the prerequisite cleanup.

## Existing Failures

Do not claim success from a dirty test signal.

- Identify whether a failure is caused by the current change.
- If a failure is unrelated and non-blocking, report it clearly and continue with targeted evidence.
- If a failure blocks validation, pause implementation and recommend fixing or isolating the existing failure first.
- Do not skip tests at the first sign of tooling friction; inspect the failure and try the repo's documented command path.

## Completion Criteria

- Relevant new or changed behavior is covered by tests or equivalent validation.
- Targeted tests pass.
- The broader relevant suite or documented validation command has been run unless blocked.
- Any skipped or blocked validation is reported with the exact reason.
