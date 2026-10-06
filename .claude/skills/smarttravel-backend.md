# SmartTravel Backend Skill

Use this skill when implementing Java/Spring Boot backend features.

## Architecture

- Package: `com.smarttravel.backend.features.<feature>.{api,domain,dto,repository,service}`
- Common: `com.smarttravel.backend.common` — ApiResponse, GlobalExceptionHandler, SecurityConfig

## Feature Creation Steps

1. Create Flyway migration: `V<N>__<feature_name>.sql`
2. Define Entity in `features/<feature>/domain/<Entity>.java`
3. Create Repository in `features/<feature>/repository/<Entity>Repository.java`
4. Create DTOs in `features/<feature>/dto/`
5. Create Service in `features/<feature>/service/<Entity>Service.java`
6. Create Controller in `features/<feature>/api/<Entity>Controller.java`

## Rules

- All endpoints return `ApiResponse<T>` envelope
- DTOs use `jakarta.validation` annotations
- Constructor injection with `final` fields only
- Never alter existing Flyway migration files
- `jpa.hibernate.ddl-auto` is `validate`

## Verification

```bash
cd backend && mvn test
```
