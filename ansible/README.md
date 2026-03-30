# Ansible Setup

This directory contains the local workstation bootstrap for this repo.

## Files

- [`main.yaml`](main.yaml): playbook entrypoint (imports `devenv.yaml`)
- [`devenv.yaml`](devenv.yaml): local development machine roles
- [`production.ini`](production.ini): local inventory

## What it installs

The `devenv` playbook applies these roles:

| Role | Tag | What it does |
|------|-----|-------------|
| `brew` | `brew` | Homebrew formulae and casks |
| `git` | `git` | Global `~/.gitconfig` |
| `nodejs` | `nodejs` | nvm + Node.js LTS |
| `kitty` | `kitty` | Kitty terminal, zsh, oh-my-zsh, Powerlevel10k, Meslo Nerd Font |
| `lazyvim` | `lazyvim` | LazyVim starter + Neovim Lua configs |
| `ai-agents` | `ai-agents` | Claude Code and Codex global configs, settings, and skills |

## Run it

From the repo root:

```bash
# Full bootstrap
ansible-playbook -i ansible/production.ini ansible/main.yaml

# Single role
ansible-playbook -i ansible/production.ini ansible/main.yaml --tags ai-agents

# Dry run
ansible-playbook -i ansible/production.ini ansible/main.yaml --check
```

The playbook detects the current user automatically via Ansible facts (`ansible_user_id`, `ansible_env.HOME`), so no per-machine edits are needed.

## What to expect

- The inventory targets `127.0.0.1` with `ansible_connection=local`, so this configures the current machine directly.
- `brew` installs development tools, CLI utilities, container/infra tooling, and GUI apps via Homebrew.
- `git` symlinks a global `~/.gitconfig` from the repo.
- `nodejs` downloads and runs the `nvm` install script, then installs the latest LTS release.
- `kitty` downloads external installers and fonts, changes the login shell to `zsh`, and symlinks kitty plus shell config into your home directory.
- `lazyvim` backs up existing Neovim state to `*.bak`, clones the LazyVim starter if needed, and symlinks the repo's Lua files into `~/.config/nvim`.

## AI Agent Config

The `ai-agents` role installs these global files:

- `ai/claude/CLAUDE.md` as `~/.claude/CLAUDE.md`
- `ai/claude/settings.json` as `~/.claude/settings.json`
- `ai/claude/skills/` as `~/.claude/skills/` (claude-init, write-commits, create-pr)
- `ai/codex/AGENTS.md` as `~/.codex/AGENTS.md`
- `ai/codex/skills/` as `~/.agents/skills/` (codex-init, write-commits, create-pr)

For Codex user config, the role seeds `ai/codex/config.toml` into `~/.codex/config.toml` when that file does not already exist. If already present, the role reconciles the tracked stable defaults while preserving local `[projects]` trust settings.

See the [main README](../README.md) for full Claude and Codex setup notes.
