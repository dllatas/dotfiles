# Backlog

Improvements and tasks queued for this repo.

| Item | Added | Notes |
|------|-------|-------|
| Ollama: move to system-level service + easy upgrade path | 2026-04-10 | Currently managed per-project (e.g. `habito/coach-ollama` owns its own launchd plist and `run-ollama.sh`). Should be a single Ansible-managed launchd service in dotfiles — one place to update the binary path, env vars, and restart policy. Brew upgrade alone does not restart the daemon; need a post-upgrade hook or `make upgrade-ollama` target so the server version stays in sync with the CLI. |
