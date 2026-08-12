# Documentation Map

Start with the smallest authoritative surface.

## Current Product

- Root `README.md`: widget catalog, platform behavior, requirements, and usage.
- `ARCHITECTURE.md`: Dart/native plugin boundaries and proof commands.
- `LIQUID_GLASS_BUILD_GUIDE.md`: native build and integration guidance.
- `superpowers/specs/`: design history for the Liquid Glass implementation.
- `product/`: consumer product contract when a behavior needs a focused doc.
- `decisions/`: lasting choices future work must inherit.
- `plans/`: one durable working-memory document for work that needs it.
- `templates/`: optional decision, plan, runbook, and Harness-improvement
  structures.

## Harness

- `HARNESS.md`: installed core and consumer boundary.
- `WORKFLOW.md`: request shape, planning, judgment, operation, validation, and
  completion.
- `plans/`: durable plans for work that spans sessions or needs recovery.

## Authority Boundary

The consumer's README, product docs, architecture, code, tests, CI, runtime
signals, and application behavior remain authoritative. Harness does not
overwrite them with upstream product assumptions.

The former SQLite control plane, story packets, trace matrix, and compatibility
documents are historical and remain recoverable through Git history rather than
remaining active sources of truth.
