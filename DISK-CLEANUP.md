# Disk Cleanup Playbook (macOS)

Process and command reference for reclaiming disk space on macOS, derived from a real cleanup session on 2026-05-18.

## Methodology — top-down drill

1. **Volume snapshot** → `df -h` (find which mount is full; on macOS, user data is on `/System/Volumes/Data`)
2. **Top-level home** → `du -h -d 1 ~ 2>/dev/null | sort -hr | head -20`
3. **Drill into the biggest dirs** → repeat `du -h -d 1 <path>` recursively
4. **Inspect specific files** → `ls -lhS <dir> | head` to spot duplicates / old versions
5. **Verify deletion freed space** → `df -h /System/Volumes/Data` after each batch

Always sort with `sort -h` (human-numeric — understands `K`/`M`/`G` suffixes from `du -h`).

## Gotchas

- **du output incomplete in `~/Library`** — some subdirs (Containers, Caches) silently fail without `2>/dev/null`; explicitly `du -sh` known offenders to cross-check
- **Deleted files don't free space if a process holds them open** — quit the relevant app first; verify with `lsof | grep <path>`
- **VM disk images don't auto-shrink** — Docker.raw, Claude vm_bundles, Lima qcow2 grow but never reclaim space inside the host filesystem; must delete the bundle entirely or use the app's own "reset disk image" UI
- **APFS purgeable space** — disk free numbers may lag actual changes; `diskutil info /` and `tmutil listlocalsnapshots /` to see what's pending

## Reclaim cheatsheet

### Dev caches (safe, regenerable)

| Path / Command | Typical Size | Notes |
|---|---|---|
| `~/.cache/huggingface` | up to 10s of GB | Each model 1-15G+. Delete dir. |
| `~/.cache/uv` | several GB | `uv cache clean` or delete. |
| `~/.npm/_cacache` | several GB | `npm cache clean --force` |
| `~/go/pkg` | several GB | `go clean -modcache` |
| `~/Library/Caches/Homebrew/downloads` | several GB | `brew cleanup --prune=all -s` (the `-s` alone won't aggressively prune casks) |
| `~/Library/Caches/{ms-playwright,go-build,com.openai.codex,Yarn,lima}` | hundreds of MB each | Plain `rm -rf` |

### Container / VM state (big, but think before deleting)

| Path | Cleanup |
|---|---|
| `~/Library/Containers/com.docker.docker/Data/vms/*/data/Docker.raw` | Quit Docker; Settings → Resources → reduce disk image size, or "Clean / Purge data" |
| `~/.local/share/containers` (Podman) | `podman machine rm <name> --force` + remove dir |
| `~/Library/Application Support/Claude/vm_bundles` | Quit Claude Desktop, then `rm -rf`; rebuilds on demand |
| `~/.lima/<vm>` | `limactl stop <vm> && limactl delete <vm> --force` |
| `~/.vagrant.d/boxes` | `vagrant box list` then `vagrant box remove <name>` |

### Toolchains (full uninstall if migrating to another machine)

```bash
# Lima
limactl delete <vm> --force && brew uninstall lima

# Vagrant
brew uninstall --cask vagrant && rm -rf ~/.vagrant.d

# Rust
rustup self uninstall          # wipes ~/.rustup AND ~/.cargo
brew uninstall rustup          # remove rustup-init brew package

# nvm — uninstall old Node versions, keep newest
nvm ls
nvm uninstall <old-version>
```

## Session log — 2026-05-18

Initial state: 460G internal disk, 380G used, **49G free** (89% capacity).

| Item | Reclaimed | Method |
|---|---|---|
| Docker VM (earlier) | ~35G | `docker system prune -a --volumes` + Docker Desktop reset |
| `~/.cache/huggingface` (Gemma 4 model) | 16G | `rm -rf` |
| `~/.cache/uv` | 9.7G | `uv cache clean` |
| Podman (binary + VM + state) | 7G | `podman machine rm`, `rm -rf ~/.local/share/containers ~/.config/containers /opt/podman` |
| `~/.local/share/nvim.bak` | 1.6G | `rm -rf` (old LazyVim install backup) |
| Homebrew cask downloads cache | 8.5G | `brew cleanup --prune=all -s` |
| Claude Desktop `vm_bundles` | 10G | Quit Claude.app first, then `rm -rf` |
| Dev caches batch (ms-playwright, codex, go-build) | ~2G | `rm -rf` |
| Dev toolchains (Lima, Vagrant, Rust, old Nodes) | ~14G | See toolchains section above |

Final state: **123G free** (71% capacity). Net reclaim ≈ 110G across the session (Docker pre-session included).

Browser caches (`~/Library/Caches/{Mozilla,Firefox}`) also self-pruned during the session — normal browser behavior, no action needed.

## Pending decisions

- **Docker (~17G in Containers)** — still installed and auto-starting. Decide whether this machine should keep it; if moving programming work to a dedicated dev laptop, candidate for full uninstall.
- **`~/Library/Caches` leftovers** (~2G, all safe): `Google` (906M), `bitwarden-updater` (479M), `com.openai.chat` (293M), `pip` (147M), `node-gyp` (116M). Single `rm -rf` batch.
- **Application Support hoarders** — Steam (1.7G), Anki (1.2G), Google (1.2G), Discord (1.1G), Slack (981M), TIDAL (927M). Only relevant if those apps are unused.
- **`~/Pictures` (29G)** — Photos library, not audited.
- **`~/Music` (63G)** — Ableton libraries and samples. Keep (music production machine).
