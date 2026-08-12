# Harness Product Model

Harness makes repository truth easier to retrieve and maintain.

## Principles

1. Repository truth wins: product documents, architecture, decisions, plans,
   code, tests, CI, runtime signals, and Git history are authoritative.
2. Load the smallest useful context. `AGENTS.md` is an entrypoint, not an
   encyclopedia.
3. Process follows work shape. Bounded work stays bounded; coordinated or
   recoverable work gets one durable plan under `docs/plans/active/`.
4. Material choices stay human-owned. Missing product policy stops mutation.
5. Behavior proves completion. Plans and status reports do not replace tests or
   other executable/observable evidence.
6. The Flutter application owns its runtime, credentials, fixtures, logs, and
   validation commands.
7. Harness maintains repository guidance and safe updates; it is not a task
   database, story tracker, or orchestrator.

## Installed Core

The repository currently uses upstream `repository-harness` core `0.1.8`.
The managed core provides:

- the compact `AGENTS.md` entrypoint and `docs/WORKFLOW.md`;
- product, decision, and execution-plan structure;
- optional runbook, decision, plan, and Harness-improvement templates;
- explicit-only repository onboarding and proposal-audit skills; and
- the checksum-verified `scripts/bin/harness` maintenance binary.

Core state and exact managed-file provenance live under `.harness-core/`.
The updater preserves local edits, stages overlapping changes for human
resolution, and supports `status`, `doctor`, dry-run updates, continuation, and
abort.

## Flutter Consumer Boundary

Harness does not define Liquid Glass behavior. The consumer contract lives in
the root `README.md`, the Flutter/Dart and Swift source, tests, example app, and
the design/build documents under `docs/`.

Use `docs/ARCHITECTURE.md` for the current plugin boundary and
`docs/LIQUID_GLASS_BUILD_GUIDE.md` for native build requirements.

## Legacy Protocol Boundary

The former SQLite `harness-cli` protocol is no longer the active Harness
workflow. Its tracked schemas and operating documents have been removed from
the current tree; Git history remains the recovery path. Existing ignored
legacy binaries or databases are not deleted automatically by the upstream
Harness core.
