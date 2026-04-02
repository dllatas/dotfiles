# Dotfiles Ansible — Agent Guide

## Purpose

Ansible playbook that bootstraps a macOS workstation: Homebrew packages,
shell/terminal config, Neovim, Git, Node.js, and AI agent configs.
Targets `localhost` only — no remote hosts.

## Stack

- Ansible (YAML playbooks, Jinja2 templates)
- Homebrew (formulae + casks)
- macOS / Darwin

## Repo Map

- `main.yaml` — playbook entrypoint (imports `devenv.yaml`)
- `devenv.yaml` — defines hosts + role list with tags
- `production.ini` — local-only inventory (`127.0.0.1`, connection=local)
- `roles/` — one directory per role:
  - `brew/` — Homebrew formulae and casks
  - `git/` — global `~/.gitconfig` symlink
  - `nodejs/` — nvm + Node.js LTS
  - `kitty/` — Kitty terminal, zsh, oh-my-zsh, Powerlevel10k
  - `lazyvim/` — LazyVim starter + Neovim Lua configs
  - `ai-agents/` — Claude Code and Codex global configs, settings, skills

## Commands

```bash
# Full bootstrap (run from repo root, one level up)
ansible-playbook -i ansible/production.ini ansible/main.yaml

# Single role
ansible-playbook -i ansible/production.ini ansible/main.yaml --tags brew

# Dry run
ansible-playbook -i ansible/production.ini ansible/main.yaml --check
```

## Branch Safety

- Before starting work, check whether the current branch is `master`
- If on `master`, suggest creating a new branch (not a worktree) before making changes

## Editing Rules

- Role structure: each role has `tasks/main.yaml`, optional `defaults/main.yaml` and `files/`
- Symlink sources use `{{ dotfiles_path }}` (resolved in `devenv.yaml` pre_tasks), never hardcoded paths
- User-specific paths use `{{ ansible_facts['env']['HOME'] }}` and `{{ ansible_facts['user_id'] }}`, never hardcoded usernames
- Keep Homebrew lists in `roles/brew/tasks/main.yaml` sorted by category with comments
- This repo is part of a larger dotfiles monorepo — the parent has AI config in `ai/claude/` and `ai/codex/`

## Testing

```bash
# Dry run is the primary validation method
ansible-playbook -i ansible/production.ini ansible/main.yaml --check

# Run a single role to test changes in isolation
ansible-playbook -i ansible/production.ini ansible/main.yaml --tags <role>
```

## Known High-Risk Areas

- `devenv.yaml` pre_tasks: the `dotfiles_path` resolution uses `git rev-parse --git-common-dir`
  to always resolve to the main checkout, even when run from a worktree — do not simplify this
- `roles/kitty/tasks/main.yaml`: changes the login shell and symlinks shell configs — can lock
  users out if the shell path is wrong
- `roles/lazyvim/tasks/main.yaml`: backs up existing Neovim state to `*.bak` before symlinking —
  the backup logic must run before any overwrites

## Commit Style

Conventional commits with scope: `feat(brew):`, `fix(ansible):`, `refactor(kitty):`, `docs(repo):`
