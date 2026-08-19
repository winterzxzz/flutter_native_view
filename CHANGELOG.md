# Changelog

## 0.3.1

- Docs: rewritten README with a widget screenshot gallery, platform support
  matrix, and FAQ.
- Meta: add a pub.dev screenshot carousel captured from the example app on
  iOS 26, and swap the `native` topic for `glassmorphism`.
- No library or plugin code changes; identical runtime behavior to 0.3.0.

## 0.3.0

- New: cross-platform shader-based `LiquidGlass` and `LiquidGlassView` with
  configurable refraction, chromatic aberration, tint, highlights, and press
  interaction.
- New: bundled fragment shader and standalone shader demo entrypoint.

## 0.2.0

- Refactor: shared `GlassPlatformView` base class — fixes lifecycle bugs and
  reduces per-widget boilerplate.
- New: `brightness` property on `LiquidGlassTabBar` to control native interface
  style (light/dark).
- Fix: theme-aware brightness on `LiquidGlassSegmentedControl`; invisible
  spinner on dark backgrounds is resolved.

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
