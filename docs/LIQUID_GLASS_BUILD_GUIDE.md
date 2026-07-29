# Liquid Glass Native v1 Build Guide

This is the maintainer guide for the accepted v1 contract in
`docs/product/liquid-glass-v1.md`. Historical pre-v1 widget-per-file guidance is
superseded by decisions `0008`, `0009`, and `0010`.

## Supported architecture

```text
typed Dart widget
  -> private immutable snapshot
  -> one UiKitView and per-view MethodChannel
  -> GlassArguments parse-first boundary
  -> one typed Swift configuration snapshot
  -> ObservableObject
  -> SwiftUI control in GlassPlatformViewHost
```

Shared Dart infrastructure:

- `glass_config_tracker.dart`: deep equality, defensive freezing, optimistic
  native-state patching, and controlled reconciliation decisions.
- `glass_platform_view.dart`: frame-coalesced updates, diagnostics, intrinsic
  sizing, handler lifecycle, and style serialization.
- `liquid_glass_style.dart`: public value types.
- `liquid_glass_theme.dart`: live inherited theme.

Shared Swift infrastructure:

- `GlassPlatformView.swift`: factory, host, parser, style/shape parsing,
  accessibility-aware custom effect, intrinsic sizing, and teardown.
- `GlassColor.swift`: the single ARGB conversion implementation.
- One control file owns only its typed configuration, observable model, SwiftUI
  root, and small `make` adapter.

## Native rules

1. The deployment target is iOS 15. Every retained root must render on iOS 15–25.
2. Keep iOS 26 symbols inside explicit `#available(iOS 26.0, *)` checks.
3. Use `.buttonStyle(.glass)` or `.glassProminent` for buttons.
4. Apply custom `glassEffect` after layout/appearance modifiers.
5. Use `GlassEffectContainer` when multiple glass buttons share one native view.
6. Do not apply glass to standard controls merely to make them look “more
   glass”; native controls own their system appearance.
7. Custom glass always honors Reduce Transparency and Reduce Motion. The
   Reduce Transparency branch must force alpha to one; iOS 15–25 must use a
   SwiftUI material rather than a translucent color substitute.
8. Parse `NSNumber` through `GlassArguments`; never cast codec numbers directly
   to only `Int` or only `Double`.
9. Publish one configuration snapshot per update. Do not add a collection of
   independently published scalar properties.
10. Never log channel payloads or text values.

## Dart synchronization rules

- `buildParams` returns a complete snapshot.
- `GlassConfigTracker` performs structural equality for maps and lists.
- `syncConfig` is automatically scheduled from widget and dependency changes.
- Native value callbacks use `dispatchControlledNativeState`, which patches
  optimistically, invokes the public callback, and schedules reconciliation in
  `finally`: accepted rebuilds deduplicate, while rejected values are sent back
  to native.
- Text input uses a persistent controller, guards native-originated writes, and
  maps selection/composing ranges through native text deltas. Do not promise
  authoritative Dart-to-native selection transport on SwiftUI 15.
- `LiquidGlassStyle` is only serialized for custom glass-surface controls.
  Standard controls serialize `LiquidGlassControlStyle`, including
  `tintColor`; do not reintroduce unused glass parameters.
- New controlled fields need a native echo-suppression test when they can emit
  at high frequency.

## Performance proof

Deterministic tests cover:

- equal nested snapshots produce no update;
- accepted native state patches prevent a controlled echo;
- rejected native state patches produce one authoritative correction;
- snapshots are defensively frozen;
- diagnostics count metadata only.

This is method-channel proof, not render-loop proof. Before claiming visual or
runtime performance, use an iOS 26 runtime and Instruments to inspect animation
hitches, SwiftUI render work, memory, and GPU cost with a realistic number of
platform views.

## Required verification

```sh
dart format lib test example/lib example/test
flutter analyze
flutter test
cd example && flutter test
cd example && flutter build ios --simulator --debug
```

Record commands and personally observed results in the current high-risk story
validation file and `.herdr-handoff/crystal.md`.
