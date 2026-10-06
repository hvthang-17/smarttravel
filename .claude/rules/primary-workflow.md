# Primary Workflow

1. Read `AGENTS.md` or `CLAUDE.md` and relevant docs before implementation.
2. Define assumptions and success criteria before implementation.
3. Determine which tier(s) are affected: `backend/`, `mobile/`, `admin/`.
4. Implement minimal code that satisfies the requested behavior.
5. Update docs when structure, workflow, or public usage changes.
6. Verify with the appropriate tier validation commands:
   - Backend: `cd backend && mvn test`
   - Mobile: `cd mobile && flutter analyze`
   - Admin: `cd admin && npm run build`
7. Report changed behavior, verification result, and unresolved questions.
