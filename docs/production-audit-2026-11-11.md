# ARKA POS — Production source audit (2026-11-11)

## Scope and safety
- Production project: Railway project `55b165ab-7701-4a9c-b246-7beb5df9710e`, environment `production`.
- Active application: `arka-pos-app` (`120a5925-578b-4472-9667-1116c55b4720`).
- Database: Railway Postgres service `ef3cc73d-eb51-4a82-940e-4de78fdcddae`, volume `postgres-volume` mounted at `/var/lib/postgresql/data`, capacity 500 MB.
- Latest observed app deployment: `SUCCESS`, 2026-11-08 13:01:26 UTC.
- No production code, service configuration, or database data was changed during this audit.
- The exact active Bun/Hono application source was extracted from the live Railway start command and archived at `archive/railway-production-source-2026-11-11.ts`.
- The active Railway app is not currently deployed from this GitHub repository. The separate `-arka-pos` service is connected to the repository's `main` branch; the live `arka-pos-app` uses the Railway Bun function image and an embedded start command.

## Confirmed implementation gaps

1. **Split tender is not supported by the sale API.** `POST /api/sales` stores only `card` or `cash`; any other value is coerced to cash. There is no representation of a sale paid partly by cash and partly by card.
2. **Returns/refunds are absent.** No `/api/returns` or `/api/refunds` route was found in the active source.
3. **Cashier shifts are absent.** No shift-open, shift-close, or cash reconciliation API was found.
4. **Audit trail is absent.** No dedicated audit-log table or audit-log API was found.
5. **Fiscal/ATK integration is absent.** No fiscal device/provider integration was found in the source. This must be treated as a separate compliance workstream, not represented as complete by a normal receipt printout.
6. **Warehouse role is absent.** User creation accepts only `manager` and `cashier` (admin is presumably provisioned separately); no warehouse-worker role is accepted.
7. **Profit is only estimated using the current product purchase price.** The report query calculates estimated cost/profit by joining sale items to the current `products.purchase_price`. There is no sale-time cost snapshot in `sale_items`, so later purchase-price changes can rewrite historical profit.
8. **Supplier obligations query ignores the selected date range.** In `GET /api/finance/data`, the obligations query checks that `$1::date IS NOT NULL` but does not apply an invoice-date range. The store filter was also wired with the wrong parameter list. The returned obligations could therefore be inconsistent with the selected period and store.
9. **Source-of-truth architecture is incomplete.** The active app is embedded in Railway configuration rather than built from this repository. The repository currently contains only a static landing page and Dockerfile on the existing branch.

## Existing functionality observed
- Authentication/session lookup and role checks.
- Stores, products, suppliers, stock, supplier receipts/invoices, supplier payments, stock write-offs, cash movements, sales, dashboard, finance, and reports APIs.
- Sales and stock deduction are performed inside a database transaction.
- Supplier invoice receipt and supplier payment operations use database transactions / row locks in key paths.

## Changes prepared on the maintenance branch (not deployed)
- Added `src/index.ts` as the maintainable application entry point, based on the archived production source.
- Added Bun project metadata, a Bun Dockerfile, README, and ignore files.
- Corrected the supplier-obligations query in `src/index.ts` to filter by the selected invoice-date range and the selected store using the same parameter list as the other finance queries.
- The original production snapshot in `archive/` remains unchanged.
- These branch changes have not been runtime-tested against PostgreSQL and have not been deployed.

## Required work before production changes
1. Configure and verify Railway volume backups for the Postgres volume. Railway documents manual and scheduled volume backups in the Postgres service's **Backups** tab. A manual volume backup is limited to 50% of the volume capacity.
2. Create a portable logical database export (`pg_dump`) and, ideally, test restore into a separate scratch database/service. Do not put database credentials or dump files in this repository.
3. Complete runtime/build verification of the new Bun/Hono/Postgres project structure and deployment configuration. Keep the active production service unchanged while preparing it.
4. Add migrations that are backward-compatible and preserve existing data.
5. Implement and test in a separate environment: split tender ledger, return/refund flow with stock/accounting reversal, shift close and cash reconciliation, audit events, warehouse role/permissions, sale-time cost snapshots, and corrected finance date filtering.
6. Handle fiscal/ATK integration only after confirming the approved Kosovo fiscalization provider/device/API and its technical requirements.
7. Run regression tests against a restored copy of production data; review the diff and obtain explicit approval before any production deploy.

## Explicit non-goals of this audit
- No production deploy.
- No database schema changes.
- No changes to users, products, invoices, stock, sales, or payments.
- No assumption that a successful Railway deployment proves POS business workflows are correct.
