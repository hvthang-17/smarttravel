# Contributing to SmartTravel

## Before Editing

1. Read `README.md`, `AGENTS.md`, and the relevant docs in `docs/`.
2. Preserve unrelated work in dirty worktrees.
3. Identify which tier(s) are affected: `backend/`, `mobile/`, `admin/`.

## Architecture Rules

### Backend (Java 21 / Spring Boot)

- Keep feature code in `features/<feature>/{api, domain, dto, repository, service}`.
- Common code in `common/` (ApiResponse, GlobalExceptionHandler, SecurityConfig).
- All REST endpoints return `ApiResponse<T>` envelope.
- Database changes require Flyway migration scripts. Never alter existing migrations.
- Use constructor injection with `final` fields. No field injection.
- DTOs use `jakarta.validation` annotations.

### Mobile (Flutter / Dart)

- Feature-First Clean Architecture: `lib/features/<feature>/{data, domain, presentation}`.
- State management: Riverpod (`flutter_riverpod`).
- Routing: GoRouter in `lib/core/router/app_router.dart`.
- Design System: Material 3 with tokens from `tasks/DESIGN-SYSTEM.md`.
- Use `const` widgets where possible. Zero warnings under `flutter analyze`.

### Admin (React / TypeScript)

- Structure: `src/features/<feature>`, `src/components`, `src/core`, `src/types`.
- Strict TypeScript mode. No `any` types.
- TypeScript interfaces must match backend DTOs.

## Verification Checks

```bash
# Backend
cd backend && mvn test

# Mobile
cd mobile && flutter analyze
cd mobile && flutter test

# Admin
cd admin && npm run build
```

Run the relevant tier checks before submitting changes.

## Commit Conventions

- Keep commits focused and use conventional commit messages when a commit is requested.
- Format: `<type>(<scope>): <description>`
- Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
- Scopes: `backend`, `mobile`, `admin`, `docs`, `ci`
- Examples:
  - `feat(backend): add itinerary generation endpoint`
  - `fix(mobile): resolve destination card overflow`
  - `docs: update agent workflow guide`

## Security

- Never commit `.env`, API keys, tokens, or credentials.
- Use `.env.example` for documenting required environment variables.
