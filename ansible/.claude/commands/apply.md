# Apply

Run the playbook for real to apply changes to the local machine.

Arguments: optional `--tags <role>` to scope to a single role

## Steps

1. Confirm with the user before running — this modifies the local system
2. Run `ansible-playbook -i ansible/production.ini ansible/main.yaml` from the repo root
3. If `--tags` was specified, append it to the command
4. Report the play recap (ok/changed/failed counts)
