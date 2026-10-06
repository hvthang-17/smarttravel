# SmartTravel Agent Guide & Development Standards

This file provides guidance to AI coding agents (OpenCode, Codex, GitHub Copilot, Windsurf, and other assistants) when working with code in this repository.

## Project Overview

- **Name**: SmartTravel
- **Type**: Monorepo (Java + Flutter + React)
- **Description**: AI-assisted travel planning platform for Da Nang, Vietnam. Backend REST API, Flutter mobile app, and React admin dashboard.

Tiers:

1. **Backend** (`backend/`): Java 21, Spring Boot 3.5.5, JPA, Flyway, Spring Security, MySQL 8.4
2. **Mobile** (`mobile/`): Dart & Flutter (Material 3), Riverpod, GoRouter, Dio
3. **Admin** (`admin/`): React 19, TypeScript, Vite

## Role & Responsibilities

Analyze user requirements, select the correct tier(s), and deliver cohesive features that meet specifications and architectural standards. Only edit code in the tier(s) requested by the user.

## Workflows

- Primary workflow: `./.claude/rules/primary-workflow.md`
- Development rules: `./.claude/rules/development-rules.md`
- Orchestration protocols: `./.claude/rules/orchestration-protocol.md`
- Documentation management: `./.claude/rules/documentation-management.md`

**IMPORTANT:** You must follow strictly the development rules in `./.claude/rules/development-rules.md`.

---

## 1. Quick Command Reference

Run commands from the corresponding project directory:

| Tier | Command | Purpose |
| --- | --- | --- |
| **Backend** | `cd backend && mvn spring-boot:run` | Start Spring Boot API |
| **Backend** | `cd backend && mvn test` | Run Spring Boot tests |
| **Backend** | `cd backend && mvn package` | Build executable jar |
| **Mobile** | `cd mobile && flutter pub get` | Install Flutter dependencies |
| **Mobile** | `cd mobile && flutter analyze` | Run Dart/Flutter static analysis |
| **Mobile** | `cd mobile && flutter test` | Run Flutter unit/widget tests |
| **Mobile** | `cd mobile && flutter run` | Launch Flutter app |
| **Admin** | `cd admin && npm install` | Install Admin web packages |
| **Admin** | `cd admin && npm run dev` | Start Vite dev server |
| **Admin** | `cd admin && npm run build` | Type-check (`tsc -b`) and build web app |
| **Admin** | `cd admin && npm run preview` | Serve Vite production build |
| **Database**| `docker compose up -d mysql` | Launch local MySQL 8.4 instance |

---

## 2. Technology Stack & Framework Conventions

### Backend (`backend/`)
- **Package base**: `com.smarttravel.backend`
- **Architecture**: Modular Clean Layered Architecture under `com.smarttravel.backend.features.<feature_name>`:
  - `api/`: HTTP REST endpoint Controllers under `/api/v1/...`
  - `service/`: Core business logic & transaction management
  - `repository/`: Spring Data JPA interfaces
  - `domain/`: JPA Entities matching Flyway schema
  - `dto/`: Request/Response payload objects with `@Valid` annotations
- **Shared**: `com.smarttravel.backend.common` — `ApiResponse<T>`, `GlobalExceptionHandler`, `SecurityConfig`, `HealthController`
- **API Envelope**: Standard response wrapper `ApiResponse<T>` with success, message, data, and timestamp.
- **Database Schema**: Flyway versioned SQL scripts in `backend/src/main/resources/db/migration/V<N>__<name>.sql`. Never alter existing migration files.
- **Validation & Security**: Input validation via `jakarta.validation.constraints`. Spring Security config in `common/SecurityConfig.java`.
- **Dependency Injection**: Constructor injection with `final` fields. No field injection.

### Mobile (`mobile/`)
- **State Management**: Flutter Riverpod (`flutter_riverpod`).
- **Routing**: Declarative routing with `go_router`.
- **HTTP Client**: `dio` for API calls to `/api/v1`.
- **Architecture**: Feature-First Clean Architecture under `lib/features/<feature_name>`:
  - `data/models/`: DTOs and data models
  - `data/repositories/`: Repository implementations
  - `presentation/providers/`: Riverpod providers
  - `presentation/screens/`: UI screens
- **Core modules**: `lib/core/` — Router (`app_router.dart`), Theme (`app_theme.dart`), Network (`api_client.dart`)
- **Design System**: Material 3, Ocean Blue (`#0077B6`) primary, Sunset Coral (`#F77F00`) secondary CTA. Full spec in `tasks/DESIGN-SYSTEM.md`.

### Admin (`admin/`)
- **Framework**: React 19, TypeScript (strict mode), Vite.
- **Architecture**: Modular layout:
  - `src/core/`: API client (`api.ts`), configuration, global styles
  - `src/components/`: Reusable layout shells, tables, forms, modals
  - `src/features/`: Feature modules (destinations, itineraries, users)
  - `src/types/`: Shared TypeScript interface definitions matching backend DTOs

---

## 3. Mandatory Agent Rules & Anti-Slop Guidelines

1. **Preserve Scope & Framework Boundaries**:
   - Only edit code in the tier requested by the user.
   - Do not introduce unapproved third-party dependencies.
   - Preserve existing security policies (e.g. `/api/v1/health` permitAll).
2. **Standardized API Contracts**:
   - All REST APIs MUST return `ApiResponse<T>` envelope.
   - All errors MUST return standard error format handled by `GlobalExceptionHandler`.
3. **Database Migration Rules**:
   - All database schema changes MUST have a versioned Flyway migration script (e.g., `V2__add_itineraries.sql`).
   - `jpa.hibernate.ddl-auto` is set to `validate`. Entity mappings must exactly match Flyway migrations.
4. **Clean Code & Anti-Slop UI**:
   - No generic placeholders (`// TODO: implement later`). Write full, functional, tested implementations.
   - Follow semantic UI design system token conventions. Avoid harsh bright default colors or unstyled containers.
5. **Validation Before Completion**:
   - Run `cd backend && mvn test` when editing backend code.
   - Run `cd mobile && flutter analyze` when editing mobile code.
   - Run `cd admin && npm run build` when editing admin code.
6. **Minimal Focused Edits**:
   - Touch only files and lines required for the requested behavior.
   - Do not rewrite, reformat, reorder, or clean up unrelated code.
   - Do not revert user changes in dirty worktrees.
7. **Security & Privacy**:
   - Never commit `.env`, API keys, tokens, or credentials.
8. **Modularization**:
   - Keep repo-owned source code files under 300 lines when practical.
   - Split focused concerns when it improves readability.

---

## 4. Documentation Index

- `docs/system-architecture.md`: Detailed end-to-end architecture & data model.
- `docs/code-standards.md`: Complete coding conventions for Java, Dart, and TypeScript.
- `docs/agent-workflow.md`: Step-by-step feature implementation guide for coding agents.
- `docs/codebase-summary.md`: Living summary of implemented features and project structure.
- `tasks/prd-smarttravel.md`: Product Requirements Document (PRD).
- `tasks/smarttravel-user-stories.md`: User stories & acceptance criteria.
- `tasks/DESIGN-DIRECTION.md`: Visual & UX design direction.
- `tasks/DESIGN-SYSTEM.md`: Design system tokens and component specifications.

---

## 5. Project Skills

Skills are provided for multiple AI tools:

| Tool | Location |
| --- | --- |
| Claude Code | `.claude/skills/` |
| Codex / OpenCode | `.agents/skills/` |
| Cursor | `.cursor/rules/` |
| Cline | `.cline/skills/` |

Available skills: `smarttravel-fullstack`, `smarttravel-backend`, `smarttravel-mobile`, `smarttravel-admin`.


