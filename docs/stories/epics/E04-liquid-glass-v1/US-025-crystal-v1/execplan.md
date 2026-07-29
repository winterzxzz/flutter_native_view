# Exec Plan

## Goal

Deliver a coherent breaking v1 of `liquid_glass_native` with authentic native
content, typed customization, correct synchronization, shared lifecycle
infrastructure, meaningful tests, migration documentation, and honest proof.

## Scope

In scope:

- Public Dart contract and retained widget migration.
- Shared Dart synchronization and diagnostics.
- Shared Swift hosting, parsing, style, accessibility, and teardown.
- iOS 15–25 and non-iOS fallbacks.
- Tests, example, README, changelog, validation report, and handoff.

Out of scope:

- Arbitrary Flutter-child native glass.
- Native navigation or modal content ownership.
- On-device Instruments runs when no iOS 26 runtime is available.

## Risk Classification

Risk flags:

- Public contracts.
- Cross-platform behavior.
- Existing behavior.
- Weak proof.
- Multi-surface architecture.

Hard gates:

- None. Breaking changes and shared-environment commands are explicitly
  authorized.

## Work Phases

1. Audit current Dart, Swift, tests, example, documentation, and tools.
2. Record product and architecture/API decisions.
3. Implement typed Dart contract and shared synchronization infrastructure.
4. Implement shared Swift infrastructure and migrate retained controls.
5. Migrate tests, example, README, and changelog.
6. Run format, analysis, unit/widget tests, and iOS compile/build checks.
7. Update validation evidence and write `.herdr-handoff/crystal.md`.

## Stop Conditions

Pause for human confirmation if:

- Authentic rendering would require copying third-party code.
- Validation requirements would need to be weakened.
- The selected native APIs do not compile with the equipped iOS 26 SDK and no
  coherent fallback exists.
