# .grounduprc.md — Project Mentor Configuration
#
# Copy this file to your project root as `.grounduprc.md` and fill in the sections
# relevant to your team. Delete sections that don't apply.
# Commit this file — all team members share the same mentor configuration.

## Preferred Patterns

<!-- List the architectural patterns your team has adopted and where they live in the codebase.
     The mentor will teach these during the patterns phase before the engineer invents their own. -->

- Example: All async operations use the outbox pattern — see `src/lib/outbox.ts`
- Example: Pagination is cursor-based via `src/lib/pagination.ts` — never offset

## Junior Traps in This Codebase

<!-- Domain-specific traps that have caused real bugs in your system.
     The mentor watches for these during grill and review. -->

- Example: `UserService.find()` returns null, not throws — callers must handle null
- Example: `processPayment()` is not idempotent — duplicate calls charge the user twice

## Codebase Context

<!-- Things the mentor needs to know to give accurate advice.
     Runtime version, key constraints, testing approach, critical paths. -->

- Stack: <!-- e.g. Node 18, TypeScript 5, Postgres 15 -->
- Integration tests: <!-- e.g. hit a real DB — do not mock -->
- Critical paths: <!-- e.g. anything touching src/payments/ requires a security probe -->

## Iron Law Adjustments

<!-- Optional: narrow relaxations for specific cases. Be conservative here.
     Relaxing an iron law increases risk — document the tradeoff. -->

<!-- Example: Skip the flow map for single-file changes with no external dependencies -->

## Internal Documentation

<!-- Links or paths to internal docs the mentor should reference when advising.
     The mentor will cite these during grill and review instead of guessing. -->

<!-- - Auth model: https://your-wiki/auth-architecture or docs/ARCHITECTURE.md -->
<!-- - Error catalogue: src/errors/README.md -->
<!-- - API contracts: docs/api/ -->
<!-- - Runbook: https://your-wiki/oncall-runbook -->

## Domain Idioms

<!-- Terms that mean something specific in your codebase — not generic engineering words.
     Without this, the mentor may use these terms differently than your team does. -->

<!-- - "Handler" means: a class that processes a single command type, lives in src/handlers/ -->
<!-- - "Service" vs "Repository": Services contain business logic; Repositories do DB access only -->
<!-- - "Event" means: a domain event published to the internal bus, not an HTTP event -->
<!-- - "Job" means: a background task processed by the queue worker in src/workers/ -->

## Required Grill Probes by Area

<!-- File path prefixes that trigger mandatory extra probes during the grill.
     Use for high-risk areas where junior engineers consistently underestimate complexity.
     The mentor will run these probes automatically when a changed file matches the prefix. -->

<!-- - src/payments/: always probe for idempotency, replay attacks, double-charge scenarios -->
<!-- - src/auth/: always probe for token expiry edge cases, concurrent session handling, privilege escalation -->
<!-- - src/migrations/: always probe for rollback plan, data loss scenarios, zero-downtime strategy -->
<!-- - src/workers/: always probe for at-least-once delivery, poison message handling, dead-letter queues -->

## Style Guide

<!-- Company-specific conventions enforced during code review.
     Generic best practices are already in the framework — list only what's specific to your team. -->

<!-- Error handling: -->
<!-- - Always extend `src/errors/AppError.ts` — never throw `new Error("message")` directly -->
<!-- - Error codes live in `src/errors/codes.ts` — add new codes there, never inline strings -->

<!-- Logging: -->
<!-- - Always use `src/lib/logger.ts` structured logger — never `console.log` -->
<!-- - Log at entry/exit of all service methods with duration -->

<!-- File and naming conventions: -->
<!-- - All new files: kebab-case (e.g. validate-token.ts, not validateToken.ts) -->
<!-- - Test files: co-located alongside source as `<filename>.test.ts` -->
<!-- - New database queries: go in the relevant repository in src/repositories/ -->

## Onboarding Context

<!-- What a new engineer needs to know in week 1 that isn't obvious from reading the code.
     The mentor uses this to give contextually accurate advice from session one. -->

<!-- Architecture decisions: -->
<!-- - We do not use ORMs — raw SQL via src/lib/db.ts and the query builder in src/lib/query.ts -->
<!-- - We use event sourcing for the orders domain — src/orders/ is append-only -->

<!-- Infrastructure: -->
<!-- - Local dev: docker-compose up starts Postgres + Redis + the queue worker -->
<!-- - Integration tests use a real Postgres instance — never mock the DB layer -->
<!-- - Staging deploys automatically on merge to main; production requires manual approval -->

<!-- Critical paths (extra care required): -->
<!-- - src/payments/ is PCI-scoped — all changes require a security probe and a second reviewer -->
<!-- - src/notifications/ is rate-limited upstream — test with the stub in test/stubs/notifications.ts -->
