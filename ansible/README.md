# Ansible Setup

This directory contains the local workstation bootstrap for this repo.

## Files

- [`main.yaml`](/Users/ds/code/dotfiles/ansible/main.yaml): playbook entrypoint
- [`devenv.yaml`](/Users/ds/code/dotfiles/ansible/devenv.yaml): local development machine roles
- [`production.ini`](/Users/ds/code/dotfiles/ansible/production.ini): local inventory

## What it installs

The active `devenv` playbook currently applies these roles:

- `brew`: Homebrew packages and casks
- `nodejs`: `nvm` plus the current Node LTS
- `kitty`: kitty config, zsh, oh-my-zsh, Powerlevel10k, Meslo Nerd Font
- `lazyvim`: LazyVim starter and the repo's Neovim config files
- `ai-agents`: global Claude Code and Codex workstation config

## Before you run it

This repo is currently hard-coded for Daniel's local user in two places:

- [`devenv.yaml`](/Users/ds/code/dotfiles/ansible/devenv.yaml): `user: ds`
- [`production.ini`](/Users/ds/code/dotfiles/ansible/production.ini): `ansible_user=ds`

If you run this on another machine or under another account, update both values first.

You also need Ansible available locally. On macOS, one common install path is:

```bash
brew install ansible
```

## Run it

From the repo root:

```bash
ansible-playbook -i ansible/production.ini ansible/main.yaml
```

Or from inside this directory:

```bash
ansible-playbook -i production.ini main.yaml
```

## What to expect

- The inventory targets `127.0.0.1` with `ansible_connection=local`, so this is meant to configure the current machine directly.
- `nodejs` downloads and runs the `nvm` install script, then installs the latest LTS release.
- `kitty` downloads external installers and fonts, changes the login shell to `zsh`, and symlinks config into `~/.config/kitty`.
- `lazyvim` backs up existing Neovim state to `*.bak`, clones the LazyVim starter if needed, and symlinks the repo's Lua files into `~/.config/nvim`.

## AI Agent Config

The `ai-agents` role installs these global files:

- [`../ai/claude/CLAUDE.md`](/Users/ds/code/dotfiles/ai/claude/CLAUDE.md) as `~/.claude/CLAUDE.md`
- [`../ai/claude/skills/claude-init/`](/Users/ds/code/dotfiles/ai/claude/skills/claude-init/SKILL.md) as `~/.claude/skills/claude-init`
- [`../ai/claude/skills/write-commits/`](/Users/ds/code/dotfiles/ai/claude/skills/write-commits/SKILL.md) as `~/.claude/skills/write-commits`
- [`../ai/claude/skills/create-pr/`](/Users/ds/code/dotfiles/ai/claude/skills/create-pr/SKILL.md) as `~/.claude/skills/create-pr`
- [`../ai/codex/AGENTS.md`](/Users/ds/code/dotfiles/ai/codex/AGENTS.md) as `~/.codex/AGENTS.md`
- [`../ai/codex/skills/codex-init/`](/Users/ds/code/dotfiles/ai/codex/skills/codex-init/SKILL.md) as `~/.agents/skills/codex-init`
- [`../ai/codex/skills/write-commits/`](/Users/ds/code/dotfiles/ai/codex/skills/write-commits/SKILL.md) as `~/.agents/skills/write-commits`
- [`../ai/codex/skills/create-pr/`](/Users/ds/code/dotfiles/ai/codex/skills/create-pr/SKILL.md) as `~/.agents/skills/create-pr`

For Codex user config, the role seeds [`../ai/codex/config.toml`](/Users/ds/code/dotfiles/ai/codex/config.toml) into `~/.codex/config.toml` only when that file does not already exist. If `~/.codex/config.toml` is already present, the role leaves it untouched so local trust settings and notice state are preserved.

See [`../README.md`](/Users/ds/code/dotfiles/README.md) for the full Claude and Codex setup notes.
