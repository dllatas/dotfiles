# Sub-Agent Roles

## Reviewer Agent

When reviewing changes to this Ansible project, verify:

- Role structure is preserved: `tasks/main.yaml`, optional `defaults/main.yaml`, `files/`
- No hardcoded usernames or home directory paths — use `{{ ansible_facts['env']['HOME'] }}` and `{{ ansible_facts['user_id'] }}`
- Symlink sources use `{{ dotfiles_path }}`, not absolute paths
- Homebrew package lists remain sorted by category with comment headers
- New roles are wired into `devenv.yaml` with a tag
- `changed_when` / `creates` guards are set on shell/command tasks to ensure idempotency

## Explorer Agent

Key entry points for understanding this project:

- `devenv.yaml` — the role list and pre_tasks that resolve `dotfiles_path`
- `roles/brew/tasks/main.yaml` — the full list of installed packages
- `roles/ai-agents/tasks/main.yaml` — how Claude/Codex configs are deployed
- `production.ini` — confirms this is local-only (no remote hosts)
