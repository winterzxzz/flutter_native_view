# 0009 Synchronized Platform-View Bridge

Date: 2026-07-30

## Status

Accepted, amended after independent review

## Context

Each pre-v1 widget partially reimplemented platform-view creation, channel
setup, untyped argument parsing, hosting, configuration updates, measurement,
and disposal. Theme dependencies did not trigger native updates, nested lists
were compared by identity, native-controlled values echoed back over the
channel, text configuration was creation-only, several models were immutable
after creation, and iOS 14–15 frequently received an empty view.

## Decision

Create one shared lifecycle seam on each side of the Flutter/native boundary.

Dart:

- One private platform-view state mixin owns creation, disposal, event counting,
  deep snapshot equality, per-frame update coalescing, intrinsic-size revision
  handling, accepted-value echo suppression, and rejected-value
  reconciliation.
- Public types produce private serialized snapshots; raw maps are not exported.
- Optional `LiquidGlassDiagnostics` records metadata-only traffic counts.

Swift:

- One `GlassPlatformViewHost` owns the transparent container,
  `UIHostingController`, method channel, update dispatch, measurement, and
  teardown.
- One `GlassArguments` parser converts unknown channel payloads to typed and
  clamped values before models consume them.
- Shared style, shape, control-style, accessibility, and color parsing live in
  infrastructure rather than individual controls.
- Every retained root is hosted on iOS 15+. iOS 26-only symbols remain inside
  explicit availability checks.

## Alternatives Considered

1. Generate a dedicated channel class per widget. Rejected for v1 because the
   small protocol is stable and code generation would add a build dependency
   without removing the platform-view lifecycle cost.
2. Use one global channel for all view instances. Rejected because platform
   views have independent lifetimes, event ordering, and disposal; a router
   would recreate instance bookkeeping at a less local seam.
3. Keep full-snapshot updates without accepted-value echo suppression.
   Rejected because continuous sliders and text fields would generate
   redundant round trips. The final design still reconciles rejected values;
   suppressing that correction would violate controlled-widget semantics.

## Consequences

Positive:

- Lifecycle and parsing fixes apply to every retained control.
- Accepted controlled native events require one native-to-Dart event and no
  echo update. Rejected events require one authoritative Dart-to-native
  correction after the callback frame.
- Equal or coalesced rebuilds produce no redundant channel traffic.
- Deterministic counters make traffic regressions testable.

Tradeoffs:

- One platform view and hosting controller remain necessary per standalone
  control.
- Full configuration snapshots are still sent when a meaningful field changes;
  the snapshot is small and keeps update ordering atomic.
- Platform-view GPU, memory, and frame-time costs still require Instruments on
  an iOS 26 runtime.

## Follow-Up

- Consider a second grouped-control adapter only when a real call site needs a
  mixed native control cluster; one adapter is not enough to justify that seam.
