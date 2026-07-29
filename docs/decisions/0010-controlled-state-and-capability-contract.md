# 0010 Controlled State And Capability Contract

Date: 2026-07-30

## Status

Accepted

## Context

Independent final review found that optimistic native setters could remain
changed when a Dart callback rejected a value, and that shared style/text APIs
promised capabilities some supported platforms could not independently apply.
It also found that accessibility and older-iOS fallback wording was stronger
than the implementation.

## Decision

- Treat Dart widget values as authoritative for switch, checkbox, slider,
  stepper, segmented, date, and color controls. Native events are optimistic,
  but every event schedules a post-frame reconciliation: accepted rebuilds
  deduplicate; rejected events are reverted.
- Restrict `LiquidGlassStyle` to custom glass surfaces. Standard Apple controls
  receive `LiquidGlassControlStyle` only, including an explicit `tintColor`.
- Model autocorrection and suggestions as one boolean because SwiftUI does not
  expose independent suggestion control across iOS 15-26.
- Preserve/infer Flutter selection and composing ranges through native text
  deltas, while explicitly not promising Dart-to-native selection transport.
- Use SwiftUI material on iOS 15-25 custom surfaces and force fully opaque
  color under Reduce Transparency.
- Support Material date-picker years 1 through 9999 with value-relative default
  bounds instead of hardcoded product dates.

## Consequences

- Rejected native interactions generate one necessary correction update.
- Some v1 draft constructors lose a `style` parameter before release; this is a
  deliberate narrowing that removes silent no-ops.
- Standard-control accent customization moves from glass tint to
  `LiquidGlassControlStyle.tintColor`.
- Text selection/composing synchronization is best-effort for native-originated
  text changes because the oldest supported SwiftUI API does not expose the
  authoritative ranges.

## Verification

- Shared method-channel tests cover accepted and rejected controlled events.
- Parameterized tests cover all seven controlled value families.
- Widget/unit tests cover control size, date extremes, tint routing, nullable
  clearing, and text editing range mapping.
- The iOS simulator build compiles the material and accessibility branches with
  the iOS 26 SDK.
