# SmartTravel Coding Standards

## 1. Java / Spring Boot Standards
- **Java Version**: 21
- **REST Endpoints**: `@RequestMapping("/api/v1/...")`
- **Dependency Injection**: Use constructor injection with `final` fields. Avoid field injection (`@Autowired` on fields).
- **Validation**: Use `@Valid` on controller methods receiving DTOs with `jakarta.validation.constraints` (`@NotBlank`, `@NotNull`, `@Min`, `@Max`, `@Size`).
- **Flyway**: Migrations strictly in `backend/src/main/resources/db/migration/V<N>__<name>.sql`.

## 2. Dart / Flutter Standards
- **SDK**: Dart `>=3.5.0 <4.0.0`, Flutter 3.x.
- **State Management**: Use `flutter_riverpod`.
- **Routing**: `go_router` registered in `core/router/app_router.dart`.
- **Formatting**: Zero warnings under `flutter analyze`.
- **Anti-Slop UI**: Use `AppTheme` token colors, proper padding/margin scales (8, 12, 16, 24), elevation levels, and proper semantic icons.

## 3. TypeScript / React Standards
- **TypeScript**: Strict mode enabled. Explicit return types on functions. No `any` type usage.
- **State & Data Fetching**: Async API calls handled through typed services.
- **Build Verification**: `npm run build` must run `tsc -b` cleanly without errors.
