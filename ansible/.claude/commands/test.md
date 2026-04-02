# Test

Dry-run the full playbook to validate changes without applying them.

Arguments: optional `--tags <role>` to scope the check to a single role

## Steps

1. Run `ansible-playbook -i ansible/production.ini ansible/main.yaml --check` from the repo root (one level up from this directory)
2. If `--tags` was specified, append it to the command
3. Report any failures or warnings
