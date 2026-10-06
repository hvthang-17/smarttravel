# Coding Agent End-to-End Workflow

Follow this procedure when implementing user requests in SmartTravel:

## Step 1: Requirements & Context Inspection
1. Read `tasks/prd-smarttravel.md` for feature logic and data requirements.
2. Read `AGENTS.md` and `CLAUDE.md` for tier guidelines.
3. Check existing schema in `backend/src/main/resources/db/migration/`.

## Step 2: Implementation Sequence

### For Backend:
1. Create versioned Flyway migration script `V<N>__<feature_name>.sql` if table schema changes.
2. Define Entity in `features/<feature>/domain/<Entity>.java`.
3. Create Repository in `features/<feature>/repository/<Entity>Repository.java`.
4. Create Service interface & implementation in `features/<feature>/service/`.
5. Create DTOs in `features/<feature>/dto/`.
6. Create Controller in `features/<feature>/api/<Entity>Controller.java` returning `ApiResponse<T>`.

### For Mobile:
1. Define DTO/Model in `lib/features/<feature>/data/models/`.
2. Implement Repository in `lib/features/<feature>/data/repositories/`.
3. Create Riverpod Provider in `lib/features/<feature>/presentation/providers/`.
4. Create Screen/UI in `lib/features/<feature>/presentation/screens/`.
5. Add route to `lib/core/router/app_router.dart`.

### For Admin:
1. Define TypeScript interface in `admin/src/types/<feature>.ts`.
2. Add API request handler in `admin/src/services/` or `admin/src/core/api.ts`.
3. Create View/Form component in `admin/src/features/<feature>/`.

## Step 3: Verification & Quality Assurance
- Run `mvn test` in `backend/`
- Run `flutter analyze` in `mobile/`
- Run `npm run build` in `admin/`
