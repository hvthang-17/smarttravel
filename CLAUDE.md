# CLAUDE.md — Claude Code Instructions for SmartTravel

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**SmartTravel** is an AI-assisted travel planning platform for Da Nang, Vietnam.
Monorepo with three tiers:

- `backend/` — Java 21 / Spring Boot 3.5.5 REST API, MySQL 8.4, Flyway, Spring Security
- `mobile/` — Flutter (Material 3, Riverpod, GoRouter, Dio)
- `admin/` — React 19 / TypeScript / Vite web admin dashboard

## Role & Responsibilities

Analyze user requirements, select the correct tier(s), and deliver cohesive features that meet specifications and architectural standards across all affected tiers.

## Workflows

- Primary workflow: `./.claude/rules/primary-workflow.md`
- Development rules: `./.claude/rules/development-rules.md`
- Orchestration protocols: `./.claude/rules/orchestration-protocol.md`
- Documentation management: `./.claude/rules/documentation-management.md`

**IMPORTANT:** You must follow strictly the development rules in `./.claude/rules/development-rules.md`.
**IMPORTANT:** Before you plan or proceed with any implementation, always read `./AGENTS.md` first to get context.
**IMPORTANT:** Sacrifice grammar for the sake of concision when writing reports.
**IMPORTANT:** In reports, list any unresolved questions at the end, if any.

---

## 1. Fast Validation Commands

Run from the corresponding tier directory:

```bash
# Backend (Spring Boot)
cd backend && mvn test
cd backend && mvn package -DskipTests

# Mobile (Flutter)
cd mobile && flutter analyze
cd mobile && flutter test

# Admin (React / TS)
cd admin && npm run build

# Database
docker compose up -d mysql
```

---

## 2. Code Standards & Architecture Guidelines

### Backend Rules (Java 21 / Spring Boot)

1. Package location: `com.smarttravel.backend.features.<feature>` or `com.smarttravel.backend.common`.
2. REST Controllers MUST return `ApiResponse<T>` envelope.
3. DTOs MUST use `jakarta.validation` annotations (`@NotNull`, `@NotBlank`, `@Size`, etc.).
4. Database migrations MUST be added to `src/main/resources/db/migration/V<N>__<name>.sql`. Never alter existing migration files.
5. Spring Security is enabled (`SecurityConfig.java`). Endpoints require permitAll or authenticated configuration.
6. Use constructor injection with `final` fields. Avoid field injection.

### Mobile Rules (Flutter / Dart)

1. Structure: Feature-First Clean Architecture (`lib/features/<feature>/data`, `domain`, `presentation`).
2. State Management: Use Flutter Riverpod (`@riverpod` or `StateNotifierProvider` / `NotifierProvider`).
3. Routing: Use GoRouter in `lib/core/router/app_router.dart`.
4. Formatting & Analysis: Zero warnings under `flutter analyze`. Use `const` widgets where possible.
5. Design System: Material 3, Ocean Blue (`#0077B6`) primary, Sunset Coral (`#F77F00`) secondary CTA. Reference `tasks/DESIGN-SYSTEM.md`.
6. Anti-Slop UI: Use semantic token colors, proper padding/margin scales (8, 12, 16, 24), elevation levels, and proper semantic icons.

### Admin Rules (React / TypeScript)

1. Strict TypeScript mode enabled. No `any` types.
2. Structure: `src/features/<feature>`, `src/components`, `src/core`, `src/types`.
3. Type-checking MUST pass clean with `tsc -b` during build (`npm run build`).

---

## 3. Workflow for Feature Generation

When asked to create or update a feature end-to-end:

1. **Backend**:
   - Add Flyway SQL migration if new tables/columns are needed.
   - Create Entity (`domain`), Repository (`repository`), DTOs (`dto`), Service (`service`), and Controller (`api`).
2. **Mobile**:
   - Add model/DTO in `data/models/`, repository in `data/repositories/`, Riverpod provider in `presentation/providers/`, and UI screen in `presentation/screens/`.
   - Register route in `app_router.dart`.
3. **Admin**:
   - Add TypeScript types in `src/types/`, API service call in `src/core/api.ts`, and React view component in `src/features/`.
4. **Verification**:
   - Run Maven, Flutter, or Vite build commands to confirm zero compile errors.

---

## 4. Non-Negotiable Rules

- Minimal focused edits only. Touch only files and lines required for the requested behavior.
- Do not rewrite, reformat, reorder, or clean up unrelated code unless required by the task.
- Never commit `.env`, API keys, tokens, or credentials.
- Do not revert user changes in dirty worktrees.
- Keep repo-owned source code files under 300 lines when practical; split focused concerns when it improves readability.
- No generic placeholders (`// TODO: implement later`). Write full, functional implementations.
- All REST APIs MUST return `ApiResponse<T>` envelope.
- All database schema changes MUST have a versioned Flyway migration script.

---

## 5. Project Skills

Available skills in `.claude/skills/`:

- **smarttravel-fullstack**: Full-stack feature development across all three tiers.
- **smarttravel-backend**: Java/Spring Boot API, JPA entities, Flyway migrations, service layer.
- **smarttravel-mobile**: Flutter/Dart, Riverpod, GoRouter, Dio, Material 3 design system.
- **smarttravel-admin**: React 19, TypeScript, Vite, admin dashboard features.

---

## 6. Documentation

Keep all important docs in `./docs` folder:

```
./docs
├── system-architecture.md
├── code-standards.md
├── agent-workflow.md
└── codebase-summary.md
```

Task/requirement files live in `./tasks/`:

```
./tasks
├── prd-smarttravel.md
├── smarttravel-user-stories.md
├── DESIGN-DIRECTION.md
├── DESIGN-SYSTEM.md
└── STITCH-PLAN.md
```

**IMPORTANT:** MUST READ and MUST COMPLY all INSTRUCTIONS in this `CLAUDE.md`, especially the WORKFLOWS section. This rule is MANDATORY. NON-NEGOTIABLE. NO EXCEPTIONS.
