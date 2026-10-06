# SmartTravel Admin Skill

Use this skill when implementing React/TypeScript admin dashboard features.

## Architecture

```
admin/src/
├── core/          # API client (api.ts), configuration, global styles
├── components/    # Reusable layout shells, tables, forms, modals
├── features/      # Feature modules (destinations, itineraries, users)
├── pages/         # Route pages
└── types/         # TypeScript interfaces matching backend DTOs
```

## Feature Creation Steps

1. Define TypeScript interface in `src/types/<feature>.ts`
2. Add API service call in `src/core/api.ts`
3. Create React view component in `src/features/<feature>/`

## Rules

- Strict TypeScript mode. No `any` types.
- TypeScript interfaces MUST match backend DTOs.
- Type-checking MUST pass clean with `tsc -b`.

## Verification

```bash
cd admin && npm run build
```
