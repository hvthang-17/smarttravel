# SmartTravel System Architecture

## 1. High-Level Monorepo Overview

```text
                               +-----------------------+
                               |     SmartTravel       |
                               |    MySQL 8.4 DB       |
                               +-----------+-----------+
                                           |
                                           | JPA / Flyway
                                           v
                               +-----------------------+
                               |   Spring Boot Backend |
                               |      REST API         |
                               |    (/api/v1/...)      |
                               +-----+-----------+-----+
                                     |           |
                        HTTP / REST  |           | HTTP / REST
                     (Dio Client)    |           | (Fetch API)
                                     v           v
                       +---------------+       +---------------+
                       | Flutter App   |       | React Admin   |
                       | (Mobile)      |       | (Web Site)    |
                       +---------------+       +---------------+
```

---

## 2. API Contract & Response Envelope

All REST API endpoints in SmartTravel follow a unified JSON envelope:

```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... },
  "timestamp": "2026-10-06T12:00:00Z"
}
```

Error response envelope:

```json
{
  "success": false,
  "message": "Validation failed / Entity not found",
  "errors": [
    "field 'name' cannot be blank"
  ],
  "timestamp": "2026-10-06T12:00:00Z"
}
```

---

## 3. Tier Architecture & Standards

### 3.1 Backend (Spring Boot 3.5.5 / Java 21)
- **Path**: `backend/src/main/java/com/smarttravel/backend/`
- **Package layout**:
  - `common/`: `ApiResponse<T>`, `GlobalExceptionHandler.java`, `SecurityConfig.java`, `HealthController.java`.
  - `features/destination/`: `Destination.java`, `DestinationRepository.java`, `DestinationService.java`, `DestinationController.java`, `DestinationDto.java`.
  - `features/itinerary/`: Itinerary planning models and APIs.

### 3.2 Mobile (Flutter / Material 3)
- **Path**: `mobile/lib/`
- **Package layout**:
  - `core/`: Router (`app_router.dart`), Theme (`app_theme.dart`), Network (`api_client.dart`).
  - `features/destination/`: Models, Repositories, Providers, Screens.
  - `features/itinerary/`: Route generator, Itinerary timeline screens.
  - `shared/`: Reusable components (buttons, custom cards, loaders).

### 3.3 Admin (React 19 / TypeScript / Vite)
- **Path**: `admin/src/`
- **Package layout**:
  - `core/`: API client (`api.ts`), App Shell layout.
  - `features/destinations/`: Destination management table, edit/create modals.
  - `types/`: Shared TypeScript models.
