# 0008 Liquid Glass v1 Public Contract

Date: 2026-07-30

## Status

Accepted, amended after independent review

## Context

The pre-v1 package exposes more than twenty unrelated widgets, repeated scalar
styling parameters, raw string modes, stringly selected-item IDs, shallow
layout conveniences, fixed-content presenters, and modules that do not render
Liquid Glass at all. Several advertised wrappers cannot authentically compose
arbitrary Flutter children into SwiftUI's native render tree. Preserving this
surface would make every bridge fix reinforce a weak interface.

## Decision

Ship v1 as a focused native-control library with the contract in
`docs/product/liquid-glass-v1.md`.

- Use immutable `LiquidGlassStyle`, `LiquidGlassShape`,
  `LiquidGlassControlStyle`, and `LiquidGlassThemeData` value objects.
- Apply `LiquidGlassStyle` only to controls that own a custom glass surface.
  Standard SwiftUI controls accept `LiquidGlassControlStyle` and use its
  `tintColor`; they do not expose glass shape/variant/interactivity that Apple
  cannot honestly apply.
- Use typed enums and generic Dart item values at public seams; serialize only
  private, validated bridge snapshots.
- Retain controls whose content is genuinely native and useful on all fallback
  tiers.
- Replace icon and search duplicates with named constructors.
- Retire arbitrary Flutter-child glass, placeholder presenters, progress
  wrappers, navigation/tab/toolbar shells, and shallow row conveniences.
- Raise the native deployment target to iOS 15 so every supported iOS version
  receives a real SwiftUI host and a deliberate non-glass fallback.

## Alternatives Considered

1. Preserve all public names and add style objects beside the scalar fields.
   Rejected because it leaves two competing configuration systems and retains
   modules whose product promise cannot be met.
2. Expose a single generic `LiquidGlassControl<T>` with sealed configurations.
   Rejected because callers would lose normal Flutter widget discovery and
   control-specific constructor validation.
3. Keep only a generic glass surface. Rejected because arbitrary Flutter
   content does not live in SwiftUI's render tree and therefore cannot support
   the strongest authenticity claim.

## Consequences

Positive:

- The interface is smaller, typed, discoverable, and honest about native
  composition limits.
- Styling and control behavior share one vocabulary across retained widgets.
- Breaking migration is finite and documented instead of indefinitely carrying
  pre-v1 compatibility layers.

Tradeoffs:

- Pre-v1 callers must migrate names and remove retired widgets.
- iOS 14 is no longer an install target for v1.
- Navigation shells and arbitrary-content surfaces may return only after a
  design can own the relevant native content and lifecycle correctly.
- Pre-v1 arbitrary numeric dimensions are replaced by semantic control sizes;
  callers own outer layout with normal Flutter constraints.

## Follow-Up

- Validate actual iOS 26 appearance and accessibility with a simulator/device;
  compilation alone cannot prove visual authenticity or GPU performance.
