# Orchestration Protocol

- Keep tasks scoped to concrete files and acceptance criteria.
- When a task spans multiple tiers (backend, mobile, admin), implement in dependency order: backend first, then mobile/admin.
- Use parallel work only when file ownership is disjoint across tiers.
- Never let two workers edit the same file without coordination.
- Reports should be concise and list unresolved questions at end.
- Respect project root as work context for reports and plans.
- Always identify which tier(s) a task affects before starting implementation.
