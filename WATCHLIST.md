# Project Watchlist

Tools and projects worth revisiting — not ready to adopt yet.

| Project | URL | Added | Revisit | Notes |
|---------|-----|-------|---------|-------|
| gnhf | https://github.com/kunchenguid/gnhf | 2026-06-24 | 2026-07-24 | Long-running agent orchestrator for measurable or massive tasks. Evaluate against Codex `/goal` before adopting; only useful if it preserves clean commits, budgets, and rollback discipline. |
| Lavish Editor | https://github.com/kunchenguid/lavish-axi | 2026-06-24 | 2026-07-24 | Local HTML artifact editor for interactive planning, visual reviews, and annotated feedback. Try on a complex UI plan before adding workflow guidance. |
| Lemonade | https://lemonade-server.ai | 2026-04-10 | — | Local AI server (LLM + image + speech). No Homebrew formula; macOS beta-only. Install via `.pkg` from [GitHub releases](https://github.com/lemonade-sdk/lemonade/releases/latest/download/Lemonade-10.2.0-Darwin.pkg). |
| MemPalace | https://github.com/milla-jovovich/mempalace | 2026-04-10 | 2026-05-10 | Verbatim-first local memory system, 96.6% on LongMemEval. AAAK compression not ready at small scale. Overkill for dotfiles-level memory now — revisit if cross-project semantic memory becomes useful. |
| Mermaid | https://mermaid.ai/open-source/intro/getting-started.html | 2026-06-24 | 2026-07-24 | Text-based diagrams for docs and planning; GitHub renders `mermaid` Markdown blocks natively. Evaluate Mermaid Chart/CLI only if diagrams become common enough to need editor, export, or automation support. |
| no-mistakes | https://github.com/kunchenguid/no-mistakes | 2026-06-24 | 2026-07-24 | Git push validation proxy that runs agent review, E2E checks, PR creation, and CI babysitting before forwarding. Promising but high-trust; evaluate on a low-risk repo first. |
| OpenSuperWhisper | https://github.com/starmel/OpenSuperWhisper | 2026-06-24 | — | macOS Apple Silicon dictation app with Whisper and Parakeet engines, global shortcuts, hold-to-record, drag-and-drop audio transcription, and Homebrew install via `brew install opensuperwhisper`. |
| Reasonix | https://github.com/esengine/DeepSeek-Reasonix | 2026-06-24 | 2026-07-24 | DeepSeek-native terminal coding agent optimized for prefix-cache stability, with single Go binary, MCP support, plan/sandbox mode, subagents, and local browser UI via `reasonix serve`. Evaluate as an alternate harness before adding any defaults. |
| treehouse | https://github.com/kunchenguid/treehouse | 2026-06-24 | 2026-07-24 | Worktree pool manager for parallel agent tasks. Could reduce worktree friction in normal repos; do not use for this dotfiles repo because live symlinks resolve to the main checkout. |
