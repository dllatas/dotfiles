# Add Brew Package

Add a Homebrew formula or cask to the tracked package list.

Arguments: `<package-name>` — the Homebrew formula or cask to add

## Steps

1. Run `brew info <package-name>` to verify the package exists and determine if it's a formula or cask
2. If it's a formula, add it to the appropriate category section in `roles/brew/tasks/main.yaml` under the `Install Homebrew packages` task
3. If it's a cask, add it to the appropriate category section under the `Install Cask packages` task
4. Keep the list sorted within its category section
