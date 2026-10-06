# SmartTravel Full-Stack Skill

Use this skill when implementing features that span backend, mobile, and admin tiers.

## Implementation Order

1. **Backend first**: Flyway migration → Entity → Repository → Service → DTO → Controller
2. **Mobile second**: Model → Repository → Riverpod Provider → Screen → Route registration
3. **Admin third**: TypeScript types → API service → React component

## Checklist

- [ ] Backend: Entity, DTO, Repository, Service, Controller, Flyway migration
- [ ] Backend: `ApiResponse<T>` envelope used on all endpoints
- [ ] Backend: `cd backend && mvn test` passes
- [ ] Mobile: Model, Repository, Provider, Screen, GoRouter route
- [ ] Mobile: `cd mobile && flutter analyze` passes
- [ ] Admin: TypeScript types, API client, React view
- [ ] Admin: `cd admin && npm run build` passes
- [ ] API contracts match across all tiers
