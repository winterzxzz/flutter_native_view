# Plan Crystal Intake

Date: 2026-07-29

## Source

- User prompt: refactor `liquid_glass_native` into a coherent, reusable v1
  wrapper around authentic Apple SwiftUI Liquid Glass; breaking changes are
  explicitly authorized.
- Attached file: none.
- External reference: current Apple SwiftUI Liquid Glass documentation.

## Classification

- Input type: maintenance request with a public-contract redesign.
- Lane: high-risk.
- Risk flags: public contracts, cross-platform behavior, existing behavior,
  weak proof, and multi-surface architecture.
- Hard gates: none. The user explicitly selected the breaking-change direction
  and authorized shared-environment verification commands.

## Work Item

Replace the broad, inconsistent widget catalog and repeated per-control bridge
implementations with a smaller v1 contract that renders real native SwiftUI
content, shares typed styling and lifecycle infrastructure, synchronizes live
theme and controlled state, deduplicates bridge traffic, and documents honest
platform and performance limits.

## Product And Story Records

- Product contract: `docs/product/liquid-glass-v1.md`.
- High-risk story: `docs/stories/epics/E04-liquid-glass-v1/US-025-crystal-v1/`.
- API decision: `docs/decisions/0008-liquid-glass-v1-public-contract.md`.
- Architecture decision:
  `docs/decisions/0009-synchronized-platform-view-bridge.md`.

## Validation Shape

| Layer | Expected proof |
| --- | --- |
| Unit | style/value equality, validation, config deduplication, native-echo suppression |
| Integration | widget fallbacks and controller/state behavior |
| Platform | Xcode/Swift or iOS simulator compile of the plugin and example |
| Performance | deterministic channel-update counters and deduplication tests |
| Release | format, analyze, package tests, example tests, iOS build when equipped |

## Harness Capability State

The shared Harness CLI at
`/Users/winterzxzz/Documents/Local/AppMobiles/flutter_native_view/scripts/bin/harness-cli`
was run with this Crystal worktree as its current directory. It initialized the
worktree-local `harness.db`, recorded intake #1, story `US-025`, and decisions
`0008`/`0009`. The matrix was empty before story creation. No inbound providers
are registered for impact analysis, performance benchmark, coverage, security
scan, or documentation lookup, so those capability steps are inactive clean
skips rather than external proof.
