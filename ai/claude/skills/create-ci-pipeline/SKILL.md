---
name: create-ci-pipeline
description: >
  Add Tekton Pipelines-as-Code CI to an application repository so pushes and
  internal pull requests build Docker images and push them to Harbor. Use when
  the user asks to create, add, bootstrap, or fix CI/PipelineRun/.tekton
  definitions for Netcup Harbor image builds.
---

# create-ci-pipeline

Add PaC definitions to an app repo. PaC watches `.tekton/` directly through the
GitHub App and creates `PipelineRun` objects in the `ci` namespace. No ArgoCD
app is needed for CI.

## Inputs

- `APP_NAME`: required image and pipeline name.
- `IMAGE_REPO`: default `harbor.harokilabs.com/staging/<APP_NAME>`.
- `DOCKERFILE`: default `Dockerfile`.
- `CONTEXT`: default `.`.
- `PUSH_BRANCH`: default `main`.

## Files

Create or update exactly these app-repo files unless the existing repo has a
documented variant:

- `.tekton/<APP_NAME>-push.yaml`
- `.tekton/<APP_NAME>-pr.yaml`
- `ci/scripts/build-image.sh`

Copy `ci/scripts/build-image.sh` verbatim from `dllatas/habito` when available.
The pipeline must `chmod +x` and run that script. The script handles moving vs
immutable tags, `DOCKER_CONFIG` / `REGISTRY_AUTH_FILE`, buildah layer cache
pulls before `buildah bud --layers`, and conditional push through
`CI_PUSH_IMAGE`.

## Fixed Cluster Values

Do not parameterize these:

```text
buildah image:  quay.io/buildah/stable:v1.39.2
namespace:      ci
serviceAccount: ci-services
storageClass:   longhorn-ci-ephemeral
pvcSize:        1Gi
nodeSelector:   harokilabs.com/capacity-class: general
podFsGroup:     65532
gitAuthSecret:  {{git_auth_secret}}
dockerSecret:   docker-credentials
```

## Required PaC Annotations

Each PipelineRun must include:

```yaml
pipelinesascode.tekton.dev/task: "git-clone"
pipelinesascode.tekton.dev/target-namespace: "ci"
pipelinesascode.tekton.dev/cancel-in-progress: "true"
pipelinesascode.tekton.dev/max-keep-runs: "10"
```

Push CEL:

```text
event == "push" && target_branch == "main" && files.all.exists(f, ...)
```

PR CEL:

```text
event == "pull_request" && target_branch == "main" && source_url == target_url && files.all.exists(f, ...)
```

Keep `source_url == target_url`; it prevents CI from running on fork PRs.

## Image Tags

Push pipeline for `PUSH_BRANCH=main` must push:

- Moving tag: `harbor.harokilabs.com/staging/<APP_NAME>:main`
- Immutable tag: `harbor.harokilabs.com/staging/<APP_NAME>:main-{{sha7}}`

PR pipeline must push:

- `harbor.harokilabs.com/staging/<APP_NAME>:pr-{{pull_request_number}}`

## Script Environment

The pipeline must set the variables the shared script reads:

```text
CI_IMAGE_REPO        harbor.harokilabs.com/staging/<APP_NAME>
CI_REVISION          {{revision}}
CI_SOURCE_BRANCH     {{source_branch}}    # push pipeline only
CI_GIT_TAG           {{git_tag}}          # push pipeline only
CI_IMAGE_BRANCH_TAG  pr-{{pull_request_number}}  # PR pipeline only
CI_DOCKERFILE        <DOCKERFILE>
CI_CONTEXT           <CONTEXT>
CI_PUSH_IMAGE        "true" or "false"
```

## Workflow

1. Read the app repo guidance and existing CI files before editing.
2. Resolve `APP_NAME`, `IMAGE_REPO`, `DOCKERFILE`, `CONTEXT`, and `PUSH_BRANCH`.
3. Verify `DOCKERFILE` and `CONTEXT` exist.
4. Inspect `dllatas/habito` for the current PaC YAML and shared build script when a local checkout exists; otherwise use the pattern in this skill and note that the source script was not locally verified.
5. Add `.tekton/<APP_NAME>-push.yaml` and `.tekton/<APP_NAME>-pr.yaml` with the fixed cluster values, required annotations, and tag behavior above.
6. Add `ci/scripts/build-image.sh` from `dllatas/habito` and ensure the PipelineRun runs `chmod +x ci/scripts/build-image.sh` before executing it.
7. Validate YAML syntax with the repo's existing tooling. If none exists, use an installed YAML parser such as `yq` or `ruby -e 'require "yaml"; ...'`.
8. Validate shell syntax with `bash -n ci/scripts/build-image.sh`.
9. Review the diff and commit with a conventional commit such as `ci(<APP_NAME>): add Harbor image pipeline`.

## Safety Rules

- Do not create or modify ArgoCD app registration for CI.
- Do not run CI on fork PRs.
- Do not push images outside `harbor.harokilabs.com/staging/<APP_NAME>` unless explicitly requested.
- Do not rename fixed cluster resources.
- Do not replace the shared build script with a simplified rewrite unless the user explicitly asks; copy the canonical script to avoid behavior drift.
- Report files changed, image tags produced, validation run, and any source-template verification gap.
