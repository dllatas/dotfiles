# Dotfiles Agent Guide

This repository is a personal macOS workstation bootstrap centered on Ansible, terminal tooling, kitty, and Neovim.

## Repo Map

- `ansible/`: playbooks, inventory, and roles for local machine setup
- `claude-md`: canonical Claude Code global preferences tracked in this repo
- `codex-agents.md`: canonical global Codex `AGENTS.md` content tracked in this repo
- `codex-config.toml`: stable Codex user defaults tracked in this repo
- `README.md`: human-facing setup notes

## Commands

- Read the setup docs first: `sed -n '1,220p' README.md`
- Read the Ansible docs: `sed -n '1,260p' ansible/README.md`
- Syntax-check playbooks: `ANSIBLE_LOCAL_TEMP=/tmp/ansible-local ANSIBLE_REMOTE_TMP=/tmp/ansible-remote ansible-playbook -i ansible/production.ini ansible/main.yaml --syntax-check`
- Review pending changes: `git status --short`

## Editing Rules

- Keep documentation aligned with the real install flow; do not describe automation that does not exist.
- Preserve the current split:
  - `claude-md` is for Claude Code global instructions
  - `codex-agents.md` is for Codex global instructions
  - `codex-config.toml` is for Codex user-level defaults
  - `AGENTS.md` is for this repo's Codex-specific instructions only
- If you change how Claude or Codex is configured, update `README.md` to explain both paths clearly.
- When editing Ansible docs, call out hard-coded machine-specific values such as `user: ds` and `ansible_user=ds`.

## Code Style

- Prefer small, explicit playbooks and documentation over clever abstractions.
- Keep examples concrete and runnable from the repo root.
- Match the repository's existing naming and markdown style.

## Testing Expectations

- For documentation-only changes, verify the referenced commands and paths still exist.
- For Ansible changes, run the syntax check before finishing.

## Commit Style

- Use conventional commits with scope when making commits for this repo.
- Keep commits focused and explain why the change exists.
