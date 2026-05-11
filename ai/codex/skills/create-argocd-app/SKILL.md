---
name: create-argocd-app
description: >
  Register a new application in the Netcup GitOps cluster by creating the
  ArgoCD app registration on netcup-apps main and the Helm deployment chart on
  the long-lived deployment branch. Use when the user asks to add, bootstrap,
  register, or create a new ArgoCD-managed Netcup/k3s application.
---

# create-argocd-app

Create the GitOps surface for a new Netcup application in `dllatas/netcup-apps`.

## Inputs

- `APP_NAME`: required application, release, and namespace name.
- `DEPLOY_BRANCH`: branch ArgoCD tracks for manifests. Default to `APP_NAME` when the user asks you to choose. Do not add a `codex/` prefix unless the user explicitly requests it or existing repo convention for that app requires it.
- `CONTAINER_PORT`: container/service port. Use `8080` only for nginx-style apps or when confirmed by the app repo.
- `HOSTNAME` and route values: derive from the app's documented domain pattern or ask when not discoverable.

## Preconditions

- Work in the local `netcup-apps` checkout. Prefer `$HOME/code/netcup-apps`; otherwise locate a checkout by Git remote.
- Fetch before inspecting or branching.
- Preserve unrelated local changes. If `main` or `DEPLOY_BRANCH` has unrelated uncommitted changes, stop and ask.
- Inspect an existing app chart such as `daniel-production` before writing `chart/values.yaml`; use the current chart schema over memory.

## Branch Model

- `main`: ArgoCD app registration only, always via PR.
- `DEPLOY_BRANCH`: deployment chart and values, committed and pushed directly.
- ArgoCD `source.targetRevision` must equal `DEPLOY_BRANCH` exactly.
- `DEPLOY_BRANCH` is not required to have any prefix.

## Main Branch Files

Create both files together on a feature branch from latest `origin/main`.

`bootstrap/argocd-apps/<APP_NAME>.yaml`:

```yaml
defaults:
  namespace: argocd
  project: default
  destinationServer: https://kubernetes.default.svc
  syncPolicy: null
applications:
  - name: <APP_NAME>
    annotations:
      argocd.argoproj.io/sync-wave: "141"
    source:
      repoURL: git@github.com:dllatas/netcup-apps.git
      targetRevision: <DEPLOY_BRANCH>
      path: chart
      helm:
        releaseName: <APP_NAME>
    destination:
      server: https://kubernetes.default.svc
      namespace: <APP_NAME>
```

`bootstrap/argocd-apps/<APP_NAME>.lock.yaml`:

```yaml
chartVersion: 0.0.4
releaseName: argocd-app-<APP_NAME>
namespace: argocd
```

Sync wave guidance:

- Infrastructure: `0-60`
- CI bootstrap: `60`
- PaC bootstrap: `135`
- Personal/simple deployment apps: `139-141`

Use `141` for personal/simple apps unless the user gives another wave.

## Deployment Branch Files

Create or update `DEPLOY_BRANCH` and put the deployment chart at `chart/`.

`chart/Chart.yaml` dependencies must come from `oci://harbor.harokilabs.com/helm-charts`:

```yaml
dependencies:
  - name: namespace
    version: 0.0.2
    repository: oci://harbor.harokilabs.com/helm-charts
  - name: external-secrets
    version: 0.0.4
    repository: oci://harbor.harokilabs.com/helm-charts
  - name: service-account
    version: 0.0.4
    repository: oci://harbor.harokilabs.com/helm-charts
  - name: application
    version: 0.0.4
    repository: oci://harbor.harokilabs.com/helm-charts
```

`chart/charts/` — **required, must be committed as unpacked directories**:

ArgoCD cannot fetch OCI dependencies from Harbor at sync time. Subcharts must
be vendored as unpacked directories, not `.tgz` archives — Helm fails dependency
resolution with tarballs alone in this setup.

Copy the unpacked subchart directories from an existing app on another branch:

```bash
git checkout origin/codex/daniel-production -- chart/charts/
```

This gives `chart/charts/application/`, `chart/charts/external-secrets/`,
`chart/charts/namespace/`, `chart/charts/service-account/` — each containing
at minimum a `Chart.yaml`. Commit all of them.

Do not commit only `.tgz` files — they will not work. Do not rely on ArgoCD
or Helm to fetch dependencies at sync time.

`chart/values.yaml` key requirements:

- Namespace name: `<APP_NAME>`.
- Harbor pull-secret Vault path: `secret/harbor-c3po`.
- Image: `harbor.harokilabs.com/staging/<APP_NAME>:main`.
- `imagePullPolicy: Always`.
- Service account uses the Harbor image pull secret produced by external-secrets.
- HTTPRoute uses Gateway API with parent `name: gateway`, `namespace: ingress`; do not create nginx Ingress.
- Container/service port matches `CONTAINER_PORT`.

## Workflow

1. Resolve `APP_NAME`, `DEPLOY_BRANCH`, `CONTAINER_PORT`, and route values.
2. In `netcup-apps`, fetch and verify latest `origin/main`.
3. Create or update `DEPLOY_BRANCH` from a sensible base. If `origin/<DEPLOY_BRANCH>` exists, use it. Otherwise create it from the current template branch or `origin/main` according to repo convention.
4. Add `chart/Chart.yaml`, `chart/charts/` (vendored subchart directories), and `chart/values.yaml` on `DEPLOY_BRANCH`.
5. Validate the deployment branch with `helm template <APP_NAME> chart`.
6. Commit and push `DEPLOY_BRANCH` directly. Do not force-push unless explicitly approved.
7. Switch back to latest `main` and create a feature branch for app registration.
8. Add the app YAML and lock YAML under `bootstrap/argocd-apps/`.
9. Validate using the repo's documented checks. At minimum, run YAML/Helm validation available in the repo.
10. Commit the registration branch and use the `create-pr` skill to open or draft a PR. Never push this registration directly to `main`.
11. If working from the app repo, record the mapping in repo-local agent memory: app name, `DEPLOY_BRANCH`, path `chart`, release name, namespace, and verification date.

## Safety Rules

- Do not assume `codex/` or any other branch prefix.
- Do not enable auto-sync unless explicitly requested; keep `syncPolicy: null`.
- Do not change cluster-wide infrastructure, CI bootstrap, PaC bootstrap, Gateway, Vault path, chart dependency versions, or sync-wave ranges unless the user explicitly asks.
- Do not register CI through ArgoCD; Tekton Pipelines-as-Code watches app repos directly.
- Report created branch, registration PR branch/URL if available, validation commands, and any values that required assumptions.
