---
name: deploy-netcup-app
description: >
  Deploy a new application image version to the Netcup k3s cluster by updating
  the ArgoCD-tracked branch in the netcup-apps GitOps repository. Use when the
  user asks to deploy, release, promote, roll out, bump an image tag, or update
  a Harbor image for a staging or explicitly requested production application
  on the Netcup cluster.
---

# deploy-netcup-app

Deploy by changing the image reference that ArgoCD already tracks in
`netcup-apps`.

## Parameters

- `ENV`: deployment environment. Default to `staging` when omitted or empty.
- Allowed `ENV` values: `staging`, `production`.
- Treat production as opt-in only. If `ENV=production` is not explicit in the user request, use `staging`.
- A user command to deploy, release, promote, roll out, or bump an image is authorization to update staging GitOps, commit, push, and verify rollout. Do not ask for an extra staging confirmation after resolving the app, PR, image, and tag.
- Ask before editing only when the requested target is production, the deploy target is ambiguous, the image/tag cannot be proven, or unrelated local changes would be touched.
- If the user implies production without explicitly setting `ENV=production`, stop and ask for confirmation before editing anything.

## Preconditions

- Resolve `ENV` first. Empty means `staging`; production requires explicit `ENV=production`.
- Confirm the app image was already built by Tekton from either a PR push or a merge to `master`/`main`.
- Confirm the exact Harbor image repository and tag. Never use `latest`, a partial image name, or an omitted registry.
- Work in the local `netcup-apps` checkout. Prefer `$HOME/code/netcup-apps` when present; otherwise locate a checkout by repo name or Git remote before editing.

## Workflow

1. Read the current repo's agent memory before checking `netcup-apps`. If the current project already records the `netcup-apps` ArgoCD app name, `ENV`, `source.targetRevision`, `source.path`, Helm release name, and namespace, use that cached mapping.
2. Refresh the cached mapping from `netcup-apps` `main` when memory is missing, stale, or ambiguous. For `ENV=production`, use cached memory only when it explicitly records `ENV=production`; otherwise refresh from `netcup-apps` `main`.
3. Fetch the latest repo state and inspect `main`/`master` before editing when refreshing mapping: `git fetch origin` then `git show origin/main:bootstrap/argocd-apps/<app>.yaml`.
4. Find the ArgoCD Application entry for the requested app and `ENV`. Record `source.targetRevision`, `source.path`, Helm release name, and destination namespace.
5. After verifying a mapping from `netcup-apps` `main`, update repo-local agent memory in the application repo when appropriate so future deploys do not need to rediscover it. Prefer `AGENTS.md` for Codex and `CLAUDE.md` for Claude when those files exist; otherwise follow that repo's existing agent-memory convention. Keep the memory specific: app name, `ENV`, ArgoCD app name, `source.targetRevision`, `source.path`, release name, namespace, and when it was verified.
6. Check out the branch named by `source.targetRevision`. If it is not present locally, create it from `origin/<targetRevision>`.
7. Edit the image reference under the branch path from `source.path`, most often `chart/values.yaml`. Change only the intended image tag or full image reference.
8. Validate that the new reference is explicit and points at Harbor, for example `harbor.harokilabs.com/<env-or-project>/<image>:<tag>`.
9. Validate the chart/manifests using the repo's documented commands. If no app-specific command exists, at minimum run `helm template <releaseName> <path>` when `<path>` is a Helm chart.
10. Review the diff, commit with a conventional commit such as `chore(<app>): deploy <image> <tag> to <env>`, and push the companion branch.
11. After pushing, use the Kubernetes cluster as the primary verification surface. Do not check for or invoke the ArgoCD CLI unless the user explicitly says it is configured for this session.
12. Confirm ArgoCD reconciliation through Kubernetes when cluster access is available: read the Application status with `kubectl get application -n argocd <app> -o yaml` or `kubectl get application -A` to locate it, then poll the affected Deployment/Pods in the destination namespace until the desired image appears and rollout health is clear.
13. If cluster access is unavailable, state that the GitOps branch was pushed and that verification is blocked by missing cluster access. Do not ask whether to use ArgoCD CLI as a fallback.

## Image Verification

- Prefer proving the tag exists before editing GitOps. Use whichever registry tool is already available and authenticated:
  `crane manifest harbor.harokilabs.com/staging/<image>:<tag>`, `docker manifest inspect ...`, or `regctl manifest get ...`.
- If registry auth or tooling is unavailable, inspect Tekton/GitHub build evidence and state the verification gap clearly before pushing.
- If the requested tag does not exist in Harbor, stop. Do not guess a nearby tag.

## Cluster Verification

- Prefer `kubectl` over `argocd` for deploy verification. The workstation normally has cluster access but not ArgoCD CLI login.
- Use read-only cluster checks first:
  - `kubectl get application -A | rg '<app>|<namespace>'`
  - `kubectl get application -n argocd <app> -o yaml`
  - `kubectl get deploy -n <namespace> -o wide`
  - `kubectl get pods -n <namespace> -l app.kubernetes.io/instance=<releaseName> -o wide`
- Poll the Deployment image and rollout state with `kubectl get deploy -n <namespace> <deployment> -o yaml` or targeted `jsonpath` reads. Prefer the exact Deployment name from the rendered chart or existing cluster objects.
- Do not spend time probing `argocd version`, `argocd account`, or `argocd app get` unless the user explicitly requests ArgoCD CLI use.
- Do not mutate cluster state with `kubectl apply`, `kubectl patch`, `kubectl delete`, or `kubectl rollout restart` during a normal GitOps image deploy.

## Repo-Local Memory

When working from an application repo such as `habito`, remember the verified `netcup-apps` deployment mapping in that repo's agent guidance so future deploys can skip repeated discovery.

Use a compact shape like:

```text
## Netcup Deploy

- `ENV=staging`: ArgoCD app `<app>`, netcup-apps branch `<source.targetRevision>`, path `<source.path>`, release `<releaseName>`, namespace `<namespace>`; verified from `netcup-apps` main on YYYY-MM-DD.
- `ENV=production`: ArgoCD app `<app>`, netcup-apps branch `<source.targetRevision>`, path `<source.path>`, release `<releaseName>`, namespace `<namespace>`; verified from `netcup-apps` main on YYYY-MM-DD.
```

Only store production mapping after an explicit production deploy request or explicit user instruction to record it.

## netcup-apps Branch Pattern

- `main`/`master` contains bootstrap ArgoCD app definitions in `bootstrap/argocd-apps/*.yaml`.
- Environment applications commonly use `source.repoURL: git@github.com:dllatas/netcup-apps.git`, a long-lived `source.targetRevision` branch, and `source.path: chart` or `manifests*`.
- Do not assume any branch prefix for `source.targetRevision`; use the branch name recorded in the ArgoCD Application exactly.
- The actual deploy edit happens on the `source.targetRevision` branch, not on `main`, unless the app definition on `main` says otherwise.
- `netcup-apps` `main` is the source of truth for which branch/path ArgoCD currently tracks. Repo-local memory can skip repeated discovery only when it is specific and was previously verified against `main`.

## Safety Rules

- Default to staging when `ENV` is empty.
- For staging, proceed without an additional human confirmation once the requested app/image/tag are resolved and validated.
- Require explicit `ENV=production` before production deploys, and ask for confirmation before production edits.
- Do not edit `bootstrap/argocd-apps/*.yaml` unless the ArgoCD app definition itself must change.
- Do not change chart versions, sync waves, namespaces, secrets, or unrelated image references as part of an image deploy.
- Do not force-push or rewrite shared companion branches unless the user explicitly approves.
- If the companion branch has unrelated uncommitted changes, stop and ask before proceeding.
- Report `ENV`, final app name, namespace, old image, new image, branch pushed, validation run, rollout status, and whether repo-local deployment memory was used or updated.
