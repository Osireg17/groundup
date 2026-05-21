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
