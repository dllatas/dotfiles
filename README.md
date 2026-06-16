# dotfiles

Personal workstation bootstrap for macOS, centered on Ansible-managed setup and a shared Claude Code global preferences file.

## Common Commands

Run only the AI agent config from the repo root:

```bash
ansible-playbook -i ansible/production.ini ansible/main.yaml --tags ai-agents
```

If you are already inside `ansible/`, run:

```bash
ansible-playbook -i production.ini devenv.yaml --tags ai-agents
```

Without `--tags ai-agents`, the full playbook also runs roles such as `brew`, `kitty`, `nodejs`, and the other workstation setup tasks.

## What is here

- `ansible/`: local playbooks and roles for the development environment
- `ai/claude/`: the shared global Claude Code config
- `ai/codex/`: the shared global Codex config and skills
- `AGENTS.md`: repo-scoped instructions for this dotfiles repo
- `WATCHLIST.md`: tools evaluated but not yet adopted, with revisit dates
- `BACKLOG.md`: improvements and tasks queued for this repo

## Agent config

### Claude Code

Claude Code reads global instructions from `~/.claude/CLAUDE.md`.

This repo keeps the stable Claude files in:

- [`ai/claude/CLAUDE.md`](/dotfiles/ai/claude/CLAUDE.md): global instructions installed as `~/.claude/CLAUDE.md`
- [`ai/claude/RTK.md`](/dotfiles/ai/claude/RTK.md): RTK usage guide imported by `CLAUDE.md`, installed as `~/.claude/RTK.md`
- [`ai/claude/settings.json`](/dotfiles/ai/claude/settings.json): Claude settings installed as `~/.claude/settings.json`

The Ansible playbook installs them automatically, or you can wire them manually:

1. Keep the canonical Claude files in `ai/claude/CLAUDE.md`, `ai/claude/RTK.md`, and `ai/claude/settings.json`
2. Run the Ansible playbook or symlink them into `~/.claude/`
3. Restart Claude Code sessions so the global instructions are picked up

From the repo root:

```bash
mkdir -p ~/.claude
ln -sf "$PWD/ai/claude/CLAUDE.md" ~/.claude/CLAUDE.md
ln -sf "$PWD/ai/claude/RTK.md" ~/.claude/RTK.md
ln -sf "$PWD/ai/claude/settings.json" ~/.claude/settings.json
```

To confirm they are wired correctly:

```bash
ls -l ~/.claude/CLAUDE.md
ls -l ~/.claude/RTK.md
ls -l ~/.claude/settings.json
```

Both symlink targets should point back to this repo's Claude files.

The tracked Claude settings are tuned to reduce routine permission prompts
without using full bypass mode. They set `permissions.defaultMode` to
`acceptEdits`, enable Claude's Bash sandbox with automatic approval for
sandboxed commands, allow common read-only, test/build, `ollama list`,
read-only Kubernetes inspection commands such as `kubectl get`, `kubectl describe`,
`kubectl logs`, and `kubectl top`, plus Tekton CLI commands, and keep
destructive or environment-changing commands such as `git push`, `git reset`,
package installs, Docker, mutating or interactive Kubernetes commands such as
`kubectl apply`, `kubectl delete`, `kubectl exec`, and `kubectl port-forward`,
Terraform, and Homebrew behind prompts.
They also deny common secret paths such as `.env`, `secrets/`, `~/.aws`, and
`~/.ssh`.

This repo also tracks these global Claude skills, installed by the playbook
under `~/.claude/skills/`:

- [`ai/claude/skills/claude-init/`](/dotfiles/ai/claude/skills/claude-init/SKILL.md): repo onboarding
- [`ai/claude/skills/write-commits/`](/dotfiles/ai/claude/skills/write-commits/SKILL.md): commit writing
- [`ai/claude/skills/create-pr/`](/dotfiles/ai/claude/skills/create-pr/SKILL.md): PR creation
- [`ai/claude/skills/update-docs/`](/dotfiles/ai/claude/skills/update-docs/SKILL.md): doc maintenance
- [`ai/claude/skills/deploy-netcup-app/`](/dotfiles/ai/claude/skills/deploy-netcup-app/SKILL.md): Netcup app deploys
- [`ai/claude/skills/create-argocd-app/`](/dotfiles/ai/claude/skills/create-argocd-app/SKILL.md): Netcup ArgoCD app registration
- [`ai/claude/skills/create-ci-pipeline/`](/dotfiles/ai/claude/skills/create-ci-pipeline/SKILL.md): Tekton PaC image pipelines

The `claude-init` skill uses portable project guidance: repo-root `AGENTS.md`
is the canonical guide, and repo-root `CLAUDE.md` should be a relative symlink
to `AGENTS.md`. Claude-specific subagents belong in `.claude/agents/`, not in
root `AGENTS.md`.

### OpenAI Codex

Codex has two relevant workstation-level layers:

- user config in `~/.codex/config.toml`
- global instructions in `~/.codex/AGENTS.md`

This repo tracks both:

- [`ai/codex/config.toml`](/dotfiles/ai/codex/config.toml): stable defaults for `~/.codex/config.toml`
- [`ai/codex/AGENTS.md`](/dotfiles/ai/codex/AGENTS.md): global instructions installed as `~/.codex/AGENTS.md`
- [`ai/codex/skills/codex-init/`](/dotfiles/ai/codex/skills/codex-init/SKILL.md): a global Codex skill installed at `~/.agents/skills/codex-init`
- [`ai/codex/skills/write-commits/`](/dotfiles/ai/codex/skills/write-commits/SKILL.md): a global Codex skill installed at `~/.agents/skills/write-commits`
- [`ai/codex/skills/create-pr/`](/dotfiles/ai/codex/skills/create-pr/SKILL.md): a global Codex skill installed at `~/.agents/skills/create-pr`
- [`ai/codex/skills/update-docs/`](/dotfiles/ai/codex/skills/update-docs/SKILL.md): a global Codex skill installed at `~/.agents/skills/update-docs`
- [`ai/codex/skills/deploy-netcup-app/`](/dotfiles/ai/codex/skills/deploy-netcup-app/SKILL.md): a global Codex skill installed at `~/.agents/skills/deploy-netcup-app`
- [`ai/codex/skills/create-argocd-app/`](/dotfiles/ai/codex/skills/create-argocd-app/SKILL.md): a global Codex skill installed at `~/.agents/skills/create-argocd-app`
- [`ai/codex/skills/create-ci-pipeline/`](/dotfiles/ai/codex/skills/create-ci-pipeline/SKILL.md): a global Codex skill installed at `~/.agents/skills/create-ci-pipeline`

The Ansible playbook installs the global instructions file automatically. Manual fallback:

```bash
mkdir -p ~/.codex
ln -sf "$PWD/ai/codex/AGENTS.md" ~/.codex/AGENTS.md
ln -sf "$PWD/ai/codex/RTK.md" ~/.codex/RTK.md
```

Confirm they are wired correctly:

```bash
ls -l ~/.codex/AGENTS.md
ls -l ~/.codex/RTK.md
```

The Ansible playbook seeds `~/.codex/config.toml` from [`ai/codex/config.toml`](/dotfiles/ai/codex/config.toml) when that file does not already exist. If `~/.codex/config.toml` is already present, the role reconciles the stable top-level defaults from the tracked file while preserving local `[projects]` trust entries and notice state.

The tracked defaults currently set `approval_policy = "on-request"` with `sandbox_mode = "danger-full-access"`. That combination gives Codex full local filesystem access, including Git metadata writes such as creating worktrees or branches, while still allowing approval prompts when the agent wants to ask before doing something sensitive.

The playbook also installs the global `codex-init` skill by symlinking [`ai/codex/skills/codex-init/`](/dotfiles/ai/codex/skills/codex-init/SKILL.md) into `~/.agents/skills/codex-init`.
It also installs the global `write-commits` skill by symlinking [`ai/codex/skills/write-commits/`](/dotfiles/ai/codex/skills/write-commits/SKILL.md) into `~/.agents/skills/write-commits`.
It also installs the global `create-pr` skill by symlinking [`ai/codex/skills/create-pr/`](/dotfiles/ai/codex/skills/create-pr/SKILL.md) into `~/.agents/skills/create-pr`.
It also installs the global `update-docs` skill by symlinking [`ai/codex/skills/update-docs/`](/dotfiles/ai/codex/skills/update-docs/SKILL.md) into `~/.agents/skills/update-docs`.
It also installs the global `deploy-netcup-app` skill by symlinking [`ai/codex/skills/deploy-netcup-app/`](/dotfiles/ai/codex/skills/deploy-netcup-app/SKILL.md) into `~/.agents/skills/deploy-netcup-app`.
It also installs the global `create-argocd-app` skill by symlinking [`ai/codex/skills/create-argocd-app/`](/dotfiles/ai/codex/skills/create-argocd-app/SKILL.md) into `~/.agents/skills/create-argocd-app`.
It also installs the global `create-ci-pipeline` skill by symlinking [`ai/codex/skills/create-ci-pipeline/`](/dotfiles/ai/codex/skills/create-ci-pipeline/SKILL.md) into `~/.agents/skills/create-ci-pipeline`.

The `codex-init` skill follows the same portable guidance rule as
`claude-init`: keep repo-root `AGENTS.md` canonical and make repo-root
`CLAUDE.md` a relative symlink to it when Claude compatibility is needed.

If you manage it manually, prefer copying or merging the tracked defaults instead of symlinking blindly. Codex user config often also contains local trust settings and notice state that are specific to one machine.

Example starting point:

```bash
cp ai/codex/config.toml ~/.codex/config.toml
```

If you already have `~/.codex/config.toml`, merge the stable defaults from [`ai/codex/config.toml`](/dotfiles/ai/codex/config.toml) into it instead of overwriting it wholesale. Preserve any machine-local `[projects]` trust settings and notice state you want to keep.

### This Repo's Codex Instructions

[`AGENTS.md`](/dotfiles/AGENTS.md) is still useful, but it is repo-scoped only. It helps Codex work inside this dotfiles repo and does not replace the workstation-global Codex files above.

### Keeping them aligned

The Claude and Codex files serve different products and layers, but they should express the same working preferences where that makes sense:

- `ai/claude/CLAUDE.md` for Claude global instructions
- `ai/claude/RTK.md` for RTK usage guide (imported by CLAUDE.md)
- `ai/claude/settings.json` for stable Claude settings
- `ai/claude/skills/claude-init/` for the global Claude repo-onboarding skill
- `ai/claude/skills/write-commits/` for the global Claude commit-writing skill
- `ai/claude/skills/create-pr/` for the global Claude PR-creation skill
- `ai/claude/skills/update-docs/` for the global Claude doc-maintenance skill
- `ai/claude/skills/deploy-netcup-app/` for the global Claude Netcup deploy skill
- `ai/claude/skills/create-argocd-app/` for the global Claude Netcup ArgoCD app-registration skill
- `ai/claude/skills/create-ci-pipeline/` for the global Claude Tekton PaC image-pipeline skill
- `ai/codex/AGENTS.md` for Codex global instructions
- `ai/codex/RTK.md` for RTK usage guide (imported by AGENTS.md)
- `ai/codex/config.toml` for Codex stable user defaults
- `ai/codex/skills/codex-init/` for the global Codex repo-onboarding skill
- `ai/codex/skills/write-commits/` for the global Codex commit-writing skill
- `ai/codex/skills/create-pr/` for the global Codex PR-creation skill
- `ai/codex/skills/update-docs/` for the global Codex doc-maintenance skill
- `ai/codex/skills/deploy-netcup-app/` for the global Codex Netcup deploy skill
- `ai/codex/skills/create-argocd-app/` for the global Codex Netcup ArgoCD app-registration skill
- `ai/codex/skills/create-ci-pipeline/` for the global Codex Tekton PaC image-pipeline skill

Both global instruction files now tell the agents to create and work from a git worktree in git repositories instead of editing directly in the current checkout, unless you explicitly override that for a task.

For per-repository project guidance generated by `claude-init` or
`codex-init`, prefer one shared source: root `AGENTS.md`. Root `CLAUDE.md`
should point to it with a relative symlink, while Claude-only commands,
settings, and subagents stay under `.claude/`.

If you update one of these, review the others so the guidance does not drift.

## How to run

### Prerequisites

Install Ansible on macOS:

```bash
brew install ansible
```

### Full workstation bootstrap

Run every role (brew, git, nodejs, rust, kitty, lazyvim, ai-agents):

```bash
ansible-playbook -i ansible/production.ini ansible/main.yaml
```

### Run a single role

Each role is tagged, so you can target just the parts you need:

```bash
# Only AI agent configs (Claude Code + Codex)
ansible-playbook -i ansible/production.ini ansible/main.yaml --tags ai-agents

# Only Homebrew packages
ansible-playbook -i ansible/production.ini ansible/main.yaml --tags brew

# Only git config
ansible-playbook -i ansible/production.ini ansible/main.yaml --tags git

# Only terminal + shell (kitty, zsh, oh-my-zsh, p10k)
ansible-playbook -i ansible/production.ini ansible/main.yaml --tags kitty

# Only Neovim / LazyVim
ansible-playbook -i ansible/production.ini ansible/main.yaml --tags lazyvim

# Only Node.js / nvm
ansible-playbook -i ansible/production.ini ansible/main.yaml --tags nodejs

# Only Rust / rustup
ansible-playbook -i ansible/production.ini ansible/main.yaml --tags rust
```

You can combine tags too:

```bash
# AI agents + git config only
ansible-playbook -i ansible/production.ini ansible/main.yaml --tags "ai-agents,git"
```

### Dry run

Add `--check` to preview what would change without applying anything:

```bash
ansible-playbook -i ansible/production.ini ansible/main.yaml --check
```

### Available roles

| Tag | What it does |
|-----|-------------|
| `brew` | Homebrew formulae and casks |
| `git` | Global `~/.gitconfig` |
| `nodejs` | nvm + Node.js LTS |
| `rust` | rustup-init + stable Rust toolchain |
| `kitty` | Kitty terminal, zsh, oh-my-zsh, Powerlevel10k, Atkinson Hyperlegible Next, Meslo Nerd Font glyph fallback |
| `lazyvim` | LazyVim starter + Neovim Lua configs |
| `ai-agents` | Claude Code and Codex global configs, settings, and skills |

## Cluster access

The harokilabs k3s cluster is accessible from any workstation on the tailnet via the Tailscale Kubernetes operator. Tailscale itself is installed by the `brew` role.

After joining the tailnet, configure `kubectl` to route through the operator:

```bash
tailscale configure kubeconfig harokilabs
```

This writes a `harokilabs` context to `~/.kube/config`. Switch to it with:

```bash
kubectl config use-context harokilabs
kubectl get nodes
```

**Prerequisites:**
- Tailscale must be installed and logged in (`tailscale login`)
- Your Tailscale identity (`danllatas@gmail.com`) must be on the tailnet — the ACL grant maps it to `system:masters` via the operator's auth mode
