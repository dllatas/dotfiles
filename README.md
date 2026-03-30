# dotfiles

Personal workstation bootstrap for macOS, centered on Ansible-managed setup and a shared Claude Code global preferences file.

## What is here

- `ansible/`: local playbooks and roles for the development environment
- `ai/claude/`: the shared global Claude Code config
- `ai/codex/`: the shared global Codex config and skills
- `AGENTS.md`: repo-scoped instructions for this dotfiles repo

## Agent config

### Claude Code

Claude Code reads global instructions from `~/.claude/CLAUDE.md`.

This repo keeps that content in [`ai/claude/CLAUDE.md`](/Users/ds/code/dotfiles/ai/claude/CLAUDE.md). The Ansible playbook installs it automatically, or you can wire it manually:

1. Keep the canonical content in `ai/claude/CLAUDE.md`
2. Run the Ansible playbook or symlink it into `~/.claude/CLAUDE.md`
3. Restart Claude Code sessions so the global instructions are picked up

From the repo root:

```bash
mkdir -p ~/.claude
ln -sf "$PWD/ai/claude/CLAUDE.md" ~/.claude/CLAUDE.md
```

To confirm it is wired correctly:

```bash
ls -l ~/.claude/CLAUDE.md
```

The symlink target should point back to this repo's Claude config file.

This repo also tracks the global Claude onboarding skill in [`ai/claude/skills/claude-init/`](/Users/ds/code/dotfiles/ai/claude/skills/claude-init/SKILL.md). The playbook installs it as `~/.claude/skills/claude-init`.

### OpenAI Codex

Codex has two relevant workstation-level layers:

- user config in `~/.codex/config.toml`
- global instructions in `~/.codex/AGENTS.md`

This repo tracks both:

- [`ai/codex/config.toml`](/Users/ds/code/dotfiles/ai/codex/config.toml): stable defaults for `~/.codex/config.toml`
- [`ai/codex/AGENTS.md`](/Users/ds/code/dotfiles/ai/codex/AGENTS.md): global instructions installed as `~/.codex/AGENTS.md`
- [`ai/codex/skills/codex-init/`](/Users/ds/code/dotfiles/ai/codex/skills/codex-init/SKILL.md): a global Codex skill installed at `~/.agents/skills/codex-init`
- [`ai/codex/skills/write-commits/`](/Users/ds/code/dotfiles/ai/codex/skills/write-commits/SKILL.md): a global Codex skill installed at `~/.agents/skills/write-commits`

The Ansible playbook installs the global instructions file automatically. Manual fallback:

```bash
mkdir -p ~/.codex
ln -sf "$PWD/ai/codex/AGENTS.md" ~/.codex/AGENTS.md
```

Confirm it is wired correctly:

```bash
ls -l ~/.codex/AGENTS.md
```

The Ansible playbook seeds `~/.codex/config.toml` from [`ai/codex/config.toml`](/Users/ds/code/dotfiles/ai/codex/config.toml) only when that file does not already exist. This avoids overwriting machine-local trust settings and notice state in an existing Codex config.

The playbook also installs the global `codex-init` skill by symlinking [`ai/codex/skills/codex-init/`](/Users/ds/code/dotfiles/ai/codex/skills/codex-init/SKILL.md) into `~/.agents/skills/codex-init`.

If you manage it manually, prefer copying or merging the tracked defaults instead of symlinking blindly. Codex user config often also contains local trust settings and notice state that are specific to one machine.

Example starting point:

```bash
cp ai/codex/config.toml ~/.codex/config.toml
```

If you already have `~/.codex/config.toml`, merge the stable defaults from [`ai/codex/config.toml`](/Users/ds/code/dotfiles/ai/codex/config.toml) into it instead of overwriting it.

### This Repo's Codex Instructions

[`AGENTS.md`](/Users/ds/code/dotfiles/AGENTS.md) is still useful, but it is repo-scoped only. It helps Codex work inside this dotfiles repo and does not replace the workstation-global Codex files above.

### Keeping them aligned

The Claude and Codex files serve different products and layers, but they should express the same working preferences where that makes sense:

- `ai/claude/CLAUDE.md` for Claude global instructions
- `ai/claude/skills/claude-init/` for the global Claude repo-onboarding skill
- `ai/codex/AGENTS.md` for Codex global instructions
- `ai/codex/config.toml` for Codex stable user defaults
- `ai/codex/skills/codex-init/` for the global Codex repo-onboarding skill

If you update one of these, review the others so the guidance does not drift.

## How to run the machine setup

The bootstrap entrypoint lives in [`ansible/main.yaml`](/Users/ds/code/dotfiles/ansible/main.yaml). See [`ansible/README.md`](/Users/ds/code/dotfiles/ansible/README.md) for the exact commands and the values you need to change for another machine.
