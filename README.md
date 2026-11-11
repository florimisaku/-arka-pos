# ARKA POS

ARKA POS is a Bun + Hono + PostgreSQL application.

## Source of truth

The maintainable application entry point is `src/index.ts`. The file in `archive/` is an unchanged snapshot extracted from the Railway production start command on 2026-11-11. Keep the archive immutable.

## Local development

Requirements: Bun 1.x and a PostgreSQL database.

1. Install dependencies: `bun install`
2. Set `DATABASE_URL` to a development-only PostgreSQL database URL.
3. Set a stable, random `SESSION_SECRET`.
4. Start: `bun run dev`

Never point local development or automated tests at the production database.

## Railway deployment

The current production service is still running its existing embedded source in Railway. This repository is a maintenance branch and is not connected to that live app service. Do not attach this branch to production or deploy it until:
- a Railway volume backup and logical database dump have been completed and verified;
- schema changes and migration/rollback plans are reviewed;
- the application is tested in an isolated environment using a restored database copy;
- the owner explicitly approves the production deployment.

## Safety

- Never commit database credentials, session secrets, exports, or customer data.
- Use migrations for schema changes; do not add new production schema changes to the startup `init()` routine without a reviewed migration plan.
- Fiscalization/ATK must be integrated only against an approved provider/device/API and verified requirements.
