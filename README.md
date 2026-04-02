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

## Agent config

### Claude Code

Claude Code reads global instructions from `~/.claude/CLAUDE.md`.

This repo keeps the stable Claude files in:

- [`ai/claude/CLAUDE.md`](/dotfiles/ai/claude/CLAUDE.md): global instructions installed as `~/.claude/CLAUDE.md`
- [`ai/claude/settings.json`](/dotfiles/ai/claude/settings.json): Claude settings installed as `~/.claude/settings.json`

The Ansible playbook installs them automatically, or you can wire them manually:

1. Keep the canonical Claude files in `ai/claude/CLAUDE.md` and `ai/claude/settings.json`
2. Run the Ansible playbook or symlink them into `~/.claude/`
3. Restart Claude Code sessions so the global instructions are picked up

From the repo root:

```bash
mkdir -p ~/.claude
ln -sf "$PWD/ai/claude/CLAUDE.md" ~/.claude/CLAUDE.md
ln -sf "$PWD/ai/claude/settings.json" ~/.claude/settings.json
```

To confirm they are wired correctly:

```bash
ls -l ~/.claude/CLAUDE.md
ls -l ~/.claude/settings.json
```

Both symlink targets should point back to this repo's Claude files.

This repo also tracks the global Claude onboarding skill in [`ai/claude/skills/claude-init/`](/dotfiles/ai/claude/skills/claude-init/SKILL.md), the global Claude commit-writing skill in [`ai/claude/skills/write-commits/`](/dotfiles/ai/claude/skills/write-commits/SKILL.md), the global Claude PR-creation skill in [`ai/claude/skills/create-pr/`](/dotfiles/ai/claude/skills/create-pr/SKILL.md), and the global Claude doc-maintenance skill in [`ai/claude/skills/update-docs/`](/dotfiles/ai/claude/skills/update-docs/SKILL.md). The playbook installs them as `~/.claude/skills/claude-init`, `~/.claude/skills/write-commits`, `~/.claude/skills/create-pr`, and `~/.claude/skills/update-docs`.

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

The Ansible playbook installs the global instructions file automatically. Manual fallback:

```bash
mkdir -p ~/.codex
ln -sf "$PWD/ai/codex/AGENTS.md" ~/.codex/AGENTS.md
```

Confirm it is wired correctly:

```bash
ls -l ~/.codex/AGENTS.md
```

The Ansible playbook seeds `~/.codex/config.toml` from [`ai/codex/config.toml`](/dotfiles/ai/codex/config.toml) when that file does not already exist. If `~/.codex/config.toml` is already present, the role reconciles the stable top-level defaults from the tracked file while preserving local `[projects]` trust entries and notice state.

The tracked defaults currently set `approval_policy = "on-request"` with `sandbox_mode = "danger-full-access"`. That combination gives Codex full local filesystem access, including Git metadata writes such as creating worktrees or branches, while still allowing approval prompts when the agent wants to ask before doing something sensitive.

The playbook also installs the global `codex-init` skill by symlinking [`ai/codex/skills/codex-init/`](/dotfiles/ai/codex/skills/codex-init/SKILL.md) into `~/.agents/skills/codex-init`.
It also installs the global `write-commits` skill by symlinking [`ai/codex/skills/write-commits/`](/dotfiles/ai/codex/skills/write-commits/SKILL.md) into `~/.agents/skills/write-commits`.
It also installs the global `create-pr` skill by symlinking [`ai/codex/skills/create-pr/`](/dotfiles/ai/codex/skills/create-pr/SKILL.md) into `~/.agents/skills/create-pr`.
It also installs the global `update-docs` skill by symlinking [`ai/codex/skills/update-docs/`](/dotfiles/ai/codex/skills/update-docs/SKILL.md) into `~/.agents/skills/update-docs`.

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
- `ai/claude/settings.json` for stable Claude settings
- `ai/claude/skills/claude-init/` for the global Claude repo-onboarding skill
- `ai/claude/skills/write-commits/` for the global Claude commit-writing skill
- `ai/claude/skills/create-pr/` for the global Claude PR-creation skill
- `ai/claude/skills/update-docs/` for the global Claude doc-maintenance skill
- `ai/codex/AGENTS.md` for Codex global instructions
- `ai/codex/config.toml` for Codex stable user defaults
- `ai/codex/skills/codex-init/` for the global Codex repo-onboarding skill
- `ai/codex/skills/write-commits/` for the global Codex commit-writing skill
- `ai/codex/skills/create-pr/` for the global Codex PR-creation skill
- `ai/codex/skills/update-docs/` for the global Codex doc-maintenance skill

Both global instruction files now tell the agents to create and work from a git worktree in git repositories instead of editing directly in the current checkout, unless you explicitly override that for a task.

If you update one of these, review the others so the guidance does not drift.

## How to run

### Prerequisites

Install Ansible on macOS:

```bash
brew install ansible
```

### Full workstation bootstrap

Run every role (brew, git, nodejs, kitty, lazyvim, ai-agents):

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
| `kitty` | Kitty terminal, zsh, oh-my-zsh, Powerlevel10k, Atkinson Hyperlegible Next, Meslo Nerd Font glyph fallback |
| `lazyvim` | LazyVim starter + Neovim Lua configs |
| `ai-agents` | Claude Code and Codex global configs, settings, and skills |
