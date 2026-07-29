# Changelog

## 1.0.0

- Replace repeated scalar customization with immutable `LiquidGlassStyle`,
  `LiquidGlassShape`, `LiquidGlassControlStyle`, and live
  `LiquidGlassThemeData`.
- Scope `LiquidGlassStyle` to custom glass surfaces and route standard-control
  accents through `LiquidGlassControlStyle.tintColor`, eliminating silent
  shape/variant/interactivity no-ops.
- Add typed symbols, generic segmented/menu values, typed date components, and
  controller-backed text/search input configuration.
- Share Dart deep-diffing, per-frame update coalescing, native-state echo
  suppression, intrinsic-size revision handling, disposal, and payload-free
  diagnostics across every retained control.
- Reconcile rejected optimistic native values back to authoritative Dart state
  while preserving zero-echo accepted rebuilds.
- Share Swift parse-first argument handling, hosting, channel dispatch,
  measurement, style/shape application, and teardown.
- Use native SwiftUI glass button styles and one `GlassEffectContainer` for
  button groups on iOS 26; provide real SwiftUI controls on iOS 15–25 and
  Material fallbacks elsewhere.
- Use `ultraThinMaterial` for iOS 15–25 custom surfaces and force opaque custom
  surfaces under Reduce Transparency regardless of tint alpha.
- Preserve text selection/composing ranges through native text deltas, model
  autocorrection/suggestions as one cross-version capability, support Material
  date years 1–9999, and apply semantic size to the Material switch.
- Raise the iOS deployment target to 15.0.
- Retire generic Flutter-child glass, placeholder modal presenters, progress
  wrappers, navigation/tab/toolbar shells, and shallow convenience widgets.
- Add migration guidance, deterministic bridge-traffic tests, a rebuilt v1
  gallery, and a compiled iOS simulator example.

## 0.1.0

- Add `LiquidGlassTheme` / `LiquidGlassThemeData` for app-wide glass defaults
  (tint, borderRadius, interactive, labelColor, respectAccessibility). Widgets
  resolve as explicit param ?? theme ?? built-in default.
- Honor system accessibility settings in native glass: *Reduce Transparency*
  (opaque surface) and *Reduce Motion* (no interactive touch response).
- New widgets: `LiquidGlassCard`, `LiquidGlassLabeledSwitch`,
  `LiquidGlassCheckbox`, `LiquidGlassTextField`.
- `TabItem` gains an optional `badge`.

## 0.0.2

- Add `example/example.md` with curated usage snippets so the pub.dev Example
  tab shows real widget usage instead of app boilerplate.

## 0.0.1

- Initial release of `liquid_glass_native`.
- Native Apple Liquid Glass widgets for Flutter, rendered by SwiftUI/UIKit
  platform views, using Apple's authentic `glassEffect` on iOS 26+ with a
  graceful fallback on older iOS and non-iOS platforms.
- Widgets: button, button group, icon button, switch, slider, stepper,
  segmented control, container, navigation bar, tab bar, toolbar, search bar,
  progress view, activity indicator, color picker, date picker, menu.
- Modal presenters: sheet, alert, popover.
