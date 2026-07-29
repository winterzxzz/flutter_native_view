# Overview

## Current Behavior

The package publishes a broad catalog with repeated scalar styling, untyped
bridge maps, incomplete live synchronization, inconsistent iOS fallback tiers,
weak fallback-only tests, and no deterministic method-channel traffic proof.
Some public widgets do not render Liquid Glass or cannot compose authentic
SwiftUI content as advertised.

## Target Behavior

The v1 package exposes the focused contract in
`docs/product/liquid-glass-v1.md`, implements all retained widgets on shared
Dart and Swift lifecycle infrastructure, keeps controlled values and themes
live without redundant traffic, and documents measured versus unmeasured
performance facts.

## Affected Users

- Flutter package consumers adopting the v1 public interface.
- Maintainers changing Dart widgets, Swift models, or bridge protocol behavior.
- Users on iOS 15–25 and non-iOS platforms relying on graceful fallbacks.
- VoiceOver, Reduce Transparency, Reduce Motion, and large-content users.

## Affected Product Docs

- `docs/product/liquid-glass-v1.md`
- `README.md`
- `CHANGELOG.md`
- `example/README.md`

## Non-Goals

- Rendering arbitrary Flutter widget trees inside SwiftUI.
- Claiming device GPU, energy, memory, or frame-time results without Instruments.
- Reintroducing navigation shells, modal content hosting, or mixed control
  groups in v1.
