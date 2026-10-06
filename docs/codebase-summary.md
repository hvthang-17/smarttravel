# SmartTravel Codebase Summary

This document provides a living snapshot of the SmartTravel monorepo structure, implemented features, and data model.

## Monorepo Overview

```
smarttravel/
├── backend/    # Java 21 + Spring Boot 3.5.5 REST API
├── mobile/     # Flutter + Dart mobile app
└── admin/      # React 19 + TypeScript + Vite admin dashboard
```

---

## Tier Summaries

### 1. Backend (`backend/`)

- **Package**: `com.smarttravel.backend`
- **Port**: `8080` (base path: `/api/v1`)
- **Database**: MySQL 8.4 on port `3306` (Flyway versioned migrations)
- **Security**: Spring Security configured in `common/SecurityConfig.java`

#### Implemented Features & Endpoints

| Endpoint | Method | Permitted | Description |
| --- | --- | --- | --- |
| `/api/v1/health` | GET | `permitAll` | Server health status check |
| `/api/v1/destinations` | GET | `permitAll` / Auth | List destinations |
| `/api/v1/destinations/{id}` | GET | `permitAll` / Auth | Get destination details |
| `/api/v1/destinations` | POST | Authenticated | Create new destination |

#### Key Classes

- `common/ApiResponse.java`: Standard response wrapper `{ success, message, data, timestamp }`
- `common/GlobalExceptionHandler.java`: Centralized exception handler
- `common/SecurityConfig.java`: Spring Security configuration
- `features/destination/domain/Destination.java`: Destination JPA Entity
- `features/destination/repository/DestinationRepository.java`: JPA repository
- `features/destination/service/DestinationService.java`: Business logic
- `features/destination/api/DestinationController.java`: REST controller
- `features/destination/dto/DestinationDto.java`: Input validation DTO

---

### 2. Mobile (`mobile/`)

- **Framework**: Flutter 3.x, Dart 3.x
- **Design System**: Material 3, Ocean Blue (`#0077B6`) primary
- **State**: Riverpod (`flutter_riverpod`)
- **Routing**: `go_router` (`lib/core/router/app_router.dart`)
- **HTTP**: Dio (`lib/core/network/api_client.dart`)

#### Core Modules

- `lib/core/network/api_client.dart`: Configured Dio client pointing to `/api/v1`
- `lib/core/router/app_router.dart`: App routes configuration
- `lib/core/theme/app_theme.dart`: Material 3 theme definitions matching `tasks/DESIGN-SYSTEM.md`

#### Implemented Features

- `lib/features/destination/`: Destination listing and detail screens, Riverpod providers, Dio repository

---

### 3. Admin (`admin/`)

- **Framework**: React 19, TypeScript, Vite
- **Port**: Dev server on Vite default (`5173`)
- **Build**: `npm run build` runs `tsc -b` type checking

#### Core Structure

- `src/core/api.ts`: Typed fetch/axios client
- `src/types/destination.ts`: TypeScript interfaces matching backend DTOs
- `src/features/destinations/`: Destination management view and forms

---

## Schema & Migration History

| Version | Script | Tables Created / Modified |
| --- | --- | --- |
| V1 | `V1__init.sql` | `destinations` table (id, name, description, category, latitude, longitude, opening_hours, price, created_at, updated_at) |

---

## Environment Configuration

| Property | Default | Description |
| --- | --- | --- |
| `MYSQL_DATABASE` | `smarttravel` | MySQL database name |
| `MYSQL_USER` | `smarttravel` | MySQL user |
| `MYSQL_PASSWORD` | `smarttravel` | MySQL password |
| `SPRING_DATASOURCE_URL` | `jdbc:mysql://localhost:3306/smarttravel...` | JPA connection URL |

---

## Maintenance Guidelines

- Update this file whenever new features, endpoints, tables, or tiers are added or modified.
- Keep endpoint paths, package structures, and migration history synchronized with actual source code.
