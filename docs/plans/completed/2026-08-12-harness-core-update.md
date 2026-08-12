# Execution Plan: Update Repository Harness Core

Date: 2026-08-12

## Status

Completed

## Outcome

Adopt the upstream repository-centered Harness core v0.1.8 while preserving the
Flutter plugin's product documentation and any legacy user-owned artifacts.

## Context

- Upstream: `hoangnb24/repository-harness`, `main`, release `harness-v0.1.8`.
- Consumer: Flutter plugin with existing Harness v0/SQLite guidance.
- Authority: upstream core workflow and updater; this repository's README,
  architecture, code, tests, and Liquid Glass design docs for product behavior.

## Scope

In scope:

- Install and verify the upstream `harness` core.
- Refresh the agent entrypoint and active Harness documentation.
- Remove obsolete v0 control-plane guidance and source files.

Out of scope:

- Flutter, Swift, example-app, or product behavior changes.
- Automatic deletion of legacy `harness.db`, binaries, or ignored artifacts.

## Approach

1. Install upstream core with merge-safe conflict handling.
2. Preserve product-owned docs while replacing stale Harness guidance.
3. Validate updater status, doctor, dry-run behavior, and repository hygiene.

## Risks And Recovery

- Upstream core files are tracked separately from the repository's product docs;
  use `.harness-backup/` and `.harness-core/` for recovery if needed.
- Legacy v0 files are recoverable from Git history and are not deleted from
  ignored user-owned state.

## Progress

- [x] Install core v0.1.8 and refresh `AGENTS.md`.
- [x] Replace stale active Harness documentation.
- [x] Validate and complete the migration.

## Decisions

- 2026-08-12: Keep Liquid Glass design/build docs as consumer product truth.
- 2026-08-12: Do not import upstream repository-harness source code or
  upstream-only decision history into the consumer repository.

## Validation

- `scripts/bin/harness status --json`
- `scripts/bin/harness doctor --json`
- `scripts/bin/harness update --dry-run --json`
- `git diff --check`
- Flutter checks are unchanged and out of scope for this docs/tooling migration.

## Result

Completed. Upstream Harness core `0.1.8` is installed and healthy. The active
repository guidance now uses the repository-centered workflow, while the
Flutter product docs and native plugin source remain consumer-owned. Legacy
v0 control-plane files were removed from the active tree and remain recoverable
through Git history; ignored legacy artifacts were preserved.

Validation passed:

- `scripts/bin/harness --version` -> `harness 0.1.8`.
- `scripts/bin/harness status --json` -> `current`.
- `scripts/bin/harness doctor --json` -> `healthy: true`.
- `scripts/bin/harness update --dry-run --json` -> no conflicts.
- `git diff --check` -> pass.
- `flutter analyze` -> no issues.
- `flutter test` -> 21 tests passed.
