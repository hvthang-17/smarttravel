# SmartTravel Mobile Skill

Use this skill when implementing Flutter/Dart mobile features.

## Architecture

Feature-First Clean Architecture under `lib/features/<feature>/`:

```
lib/features/<feature>/
├── data/
│   ├── models/        # DTOs and data models
│   └── repositories/  # Repository implementations
├── domain/            # Business entities, repository contracts (when needed)
└── presentation/
    ├── providers/     # Riverpod providers
    └── screens/       # UI screens and widgets
```

Core modules: `lib/core/{network, router, theme}`

## Feature Creation Steps

1. Define DTO/Model in `data/models/`
2. Implement Repository in `data/repositories/`
3. Create Riverpod Provider in `presentation/providers/`
4. Create Screen in `presentation/screens/`
5. Register route in `lib/core/router/app_router.dart`

## Rules

- State Management: Riverpod (`flutter_riverpod`)
- Routing: GoRouter
- HTTP Client: Dio
- Design System: Material 3, Ocean Blue primary, per `tasks/DESIGN-SYSTEM.md`
- Zero warnings under `flutter analyze`
- Use `const` widgets where possible
- Anti-Slop: semantic tokens, padding scales (8, 12, 16, 24), no harsh defaults

## Verification

```bash
cd mobile && flutter analyze
cd mobile && flutter test
```
