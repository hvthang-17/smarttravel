# SmartTravel agent guide

## Project overview

SmartTravel is a Da Nang trip-planning product. The intended system comprises a Flutter traveller app, a Spring Boot REST API with MySQL, and a React admin site for destination data. The repository is currently a scaffold: the backend exposes a health check and a single `destinations` migration; the mobile and admin applications each contain a starter screen. Product requirements and UI assets describe a substantially broader MVP that is not yet implemented.

## Tech stack

- `backend/`: Java 21, Spring Boot 3.5.5, Spring Web, Validation, Data JPA, Security, Flyway, and the MySQL JDBC driver; Maven builds it.
- `mobile/`: Dart (SDK `>=3.5.0 <4.0.0`) and Flutter/Material 3. Declared dependencies include Dio, Riverpod, and GoRouter, although the current app source only uses Material.
- `admin/`: React, React DOM, TypeScript (strict mode), Vite, and `@vitejs/plugin-react`; npm is used by the README.
- MySQL 8.4 is supplied locally by `docker-compose.yml`. Flyway migrations live in the backend.

## Repository structure

```text
backend/
  src/main/java/com/smarttravel/backend/       Spring Boot application and `common` web/security classes
  src/main/resources/                          Spring configuration and Flyway migrations
mobile/
  lib/main.dart                                Flutter application entry point and starter home screen
  pubspec.yaml                                 Flutter package manifest
admin/
  src/main.tsx, src/style.css                  React entry component and stylesheet
  package.json                                 Vite scripts and dependencies
tasks/                                         PRD, user stories, design system/direction, and Stitch plan
design/                                        Traveller design direction plus screen-reference images
ui-ux/                                         Organised UI/UX screenshot assets and their inventory README
docker-compose.yml                             Local MySQL service
.env.example                                  Local database environment-variable template
```

## Development commands

Run commands from the indicated directory unless noted otherwise.

| Command | Purpose |
| --- | --- |
| `docker compose up -d mysql` | Start the local MySQL 8.4 service. |
| `cd backend; mvn spring-boot:run` | Run the Spring Boot API (documented in the root README). |
| `cd backend; mvn test` | Run Maven's test lifecycle; `spring-boot-starter-test` is configured, but no test sources are currently committed. |
| `cd backend; mvn package` | Compile/package the Maven application. |
| `cd mobile; flutter pub get` | Fetch Flutter dependencies. |
| `cd mobile; flutter run` | Run the Flutter app. |
| `cd mobile; flutter analyze` | Run the Dart/Flutter analyzer; `flutter_lints` is configured. |
| `cd mobile; flutter test` | Run Flutter tests; no test directory is currently committed. |
| `cd admin; npm install` | Install admin dependencies. No lockfile is committed. |
| `cd admin; npm run dev` | Start Vite's development server. |
| `cd admin; npm run build` | Type-check with `tsc -b` and produce a Vite build. |
| `cd admin; npm run preview` | Serve the Vite production build locally. |

The admin manifest defines no lint, format, or test script. No repository-wide formatter, linter configuration, CI workflow, Maven wrapper, or committed automated-test suite was found.

## Current implementation conventions and architecture

- Backend Java is under `com.smarttravel.backend`; the application class is the Spring Boot entry point. The current HTTP endpoint uses annotated Spring MVC classes in `common`, with `/api/v1` as its controller base path. Do not treat the one existing controller/package as a complete feature-layer architecture.
- `SecurityConfig` disables CSRF, permits `/api/v1/health` and `/actuator/health`, and requires authentication for other requests. Preserve that observable policy unless the task calls for changing it.
- Flyway is enabled and JPA uses `ddl-auto: validate`; schema evolution is represented by versioned SQL under `backend/src/main/resources/db/migration/`.
- The current Flutter code uses `StatelessWidget`, `const` widgets where applicable, Material widgets, and an inline `ThemeData` in `main.dart`. No feature, routing, state-management, API-client, or shared-widget structure exists in source yet.
- The current admin entry point uses a local `App` function component, `StrictMode`, `createRoot`, and a stylesheet imported from `main.tsx`. Its CSS is plain global CSS. No component library, router, state store, API client, or admin module structure exists in source yet.
- Keep changes scoped to the requested application/module. Do not introduce a new architecture, abstraction strategy, dependency, API contract, or database schema change unless the task requires it.

## Product and UI references

- Product behavior, MVP scope, data/API requirements, risks, and open questions: read `tasks/prd-smarttravel.md` before implementing related functionality.
- Acceptance-oriented user-story detail: `tasks/smarttravel-user-stories.md`.
- For traveller UI work, `design/DESIGN-DIRECTION.md` calls itself the visual contract for future Stitch generations and points to its established navigation, semantic tokens, typography, sizing, accessibility, and anti-slop constraints. Use it before changing traveller UI.
- `tasks/DESIGN-SYSTEM.md` and `tasks/DESIGN-DIRECTION.md` contain the broader design-system and UX specifications. `tasks/STITCH-PLAN.md` gives the planned Stitch screen-generation sequence and prompts.
- `design/` and `ui-ux/user/` contain visual references; `ui-ux/README.md` inventories the screenshot layout. Treat images as references, not generated source code.

The design documents are not fully aligned in every token/navigation detail (for example, the two design directions use different colour values). For a traveller-screen conflict, raise it or follow the explicit task; do not silently merge conflicting specifications into a new rule. Current application source remains the implementation source of truth.

## Testing and validation

There are no committed unit, integration, or end-to-end test source directories. Select validation from the commands above for the area changed: Maven tests/package for backend, Flutter analyze/test for mobile, and the admin build for admin. Report commands actually run and any that could not run.

## Protected and sensitive areas

- Do not commit `.env`; use `.env.example` only as the documented variable template. Database credentials and datasource overrides are consumed by `backend/src/main/resources/application.yml`.
- Treat `docker-compose.yml`, `application.yml`, the Flyway SQL migrations, and `SecurityConfig.java` as configuration, schema, and access-control boundaries. Change them only when the task explicitly requires their behavior to change, and review their downstream effects.
- A migration must remain compatible with JPA validation and the MySQL database configured for the project.

## Git and agent workflow

- No documented branch, pull-request, or mandatory commit-message policy exists. Recent history uses subjects such as `feat(ui-ux): ...`, `docs(design): ...`, and `chore: ...`, but this is an observed pattern, not a required convention.
- Before coding, identify the target app, inspect the current nearby source, then read the relevant product/design document above. Search for an existing implementation before adding a duplicate component, utility, endpoint, or migration.
- During coding, preserve the observed boundaries and avoid unrelated refactors. Product documents describe intended requirements; confirm against current source/configuration before assuming an endpoint, data model, UI flow, or integration already exists.
- After coding, run the relevant available validation command(s), inspect the changed-file list, and report both changes and validation results.

## Source of truth

When information conflicts, use: explicit task requirements first; then current source and configuration; then the scoped documentation named above; then established patterns in the same application. The PRD contains future requirements and a recommended architecture section, so it does not by itself mean that those APIs, layers, or integrations are already implemented.

