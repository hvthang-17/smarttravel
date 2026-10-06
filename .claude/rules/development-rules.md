# Development Rules

## Principles

YAGNI, KISS, DRY. Think before coding, keep simple, edit surgically, verify concrete goals.

## Non-Negotiable Rules

### Editing

- Minimal focused edits are mandatory: touch only files and lines required for the requested behavior.
- Do not rewrite, reformat, reorder, regenerate, or clean up unrelated code unless required by the task.
- Do not create enhanced replacement files; update existing files directly.
- Preserve existing structure, comments, naming, and formatting unless change requires it.
- Do not revert user changes in dirty worktrees.
- Do not commit secrets, `.env`, API keys, or credentials.
- Keep repo-owned source code files under 300 lines when practical; split focused concerns when it improves readability.

### Backend (Java 21 / Spring Boot 3.5.5)

- Package: `com.smarttravel.backend.features.<feature>` or `com.smarttravel.backend.common`.
- All REST Controllers MUST return `ApiResponse<T>` envelope.
- DTOs MUST use `jakarta.validation` annotations.
- Database changes MUST have a versioned Flyway migration script. Never alter existing migrations.
- `jpa.hibernate.ddl-auto` is `validate`. Entity mappings must exactly match Flyway migrations.
- Use constructor injection with `final` fields. Avoid field injection.
- Preserve existing security policies.

### Mobile (Flutter / Dart)

- Feature-First Clean Architecture: `lib/features/<feature>/{data, domain, presentation}`.
- State Management: Riverpod (`flutter_riverpod`).
- Routing: GoRouter in `lib/core/router/app_router.dart`.
- Zero warnings under `flutter analyze`. Use `const` widgets where possible.
- Design System: Material 3, Ocean Blue (`#0077B6`) primary, per `tasks/DESIGN-SYSTEM.md`.
- Anti-Slop: Semantic token colors, proper padding scales (8, 12, 16, 24), no harsh defaults.

### Admin (React 19 / TypeScript / Vite)

- Strict TypeScript mode. No `any` types.
- Structure: `src/features/<feature>`, `src/components`, `src/core`, `src/types`.
- TypeScript interfaces MUST match backend DTOs.
- `npm run build` must pass cleanly.

### Cross-Tier

- All REST APIs return `ApiResponse<T>` envelope.
- All errors return standard format via `GlobalExceptionHandler`.
- No generic placeholders (`// TODO: implement later`). Write full implementations.
- Do not introduce unapproved third-party dependencies.

## Verification

- Run `cd backend && mvn test` after backend code changes.
- Run `cd mobile && flutter analyze` after mobile code changes.
- Run `cd admin && npm run build` after admin code changes.
