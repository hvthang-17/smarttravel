# Documentation Management

- Keep `README.md`, `docs/`, `AGENTS.md`, `CLAUDE.md`, and `.cursor/rules/` aligned.
- Update docs after feature structure, setup, command, or workflow changes.
- Prefer short, current examples over long stale walkthroughs.
- Remove references to files that do not exist.
- Update `docs/codebase-summary.md` when new features or modules are added.
- Task/requirement files in `tasks/` are reference documents; do not modify unless explicitly asked.

- Use `docs/README.md` as the documentation entry point. Keep architecture, development, planning and reports in their respective folders.
- `docs/planning/requirements-status.md` is the current status page; topic reports collect implementation evidence, while reports/history contains old snapshots; neither is a second current backlog.
- Rebase relative links when moving documents. Preserve historical migration checksums and distinguish implemented code from verified deployment/native UI evidence.
