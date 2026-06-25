# Design: Global glass theme, accessibility, and new widgets

Date: 2026-06-25
Status: approved

Adds three feature groups to `liquid_glass_native`, built incrementally.

## Phase A — Global glass config

### #6 LiquidGlassTheme

An `InheritedWidget` placed above the app supplies defaults so callers stop
repeating per-widget styling.

- Fields: `tint`, `borderRadius`, `interactive`, `labelColor`,
  `respectAccessibility` (default `true`).
- Lookup: `LiquidGlassTheme.of(context)` returns the nearest theme or a const
  default.
- Resolution per widget: **explicit param ?? theme value ?? existing hardcoded
  default**. Fully backward compatible — no theme means current behavior.
- Only widgets that already expose `tint`/`borderRadius`/`interactive` read the
  theme; new params are additive.

### #8 Accessibility

Handled in native SwiftUI, no Dart channel plumbing:

- A shared Swift helper reads `@Environment(\.accessibilityReduceTransparency)`;
  when on, glass views render a solid tinted fill instead of `glassEffect`.
- Reads `@Environment(\.accessibilityReduceMotion)`; when on, `.interactive()`
  is dropped so the glass does not animate on touch.
- `respectAccessibility` (from the theme, forwarded as a creation param) lets
  apps opt out. Default on.
- Non-iOS fallbacks already adapt via Material.

## Phase B — New widgets (#7)

| Widget | Approach | New native view |
| --- | --- | --- |
| `LiquidGlassCard` | Dart wrapper over `LiquidGlassContainer` + padding + `child` + optional `onTap` | No |
| `TabItem.badge` | Add `badge` (`String?`) to `TabItem`; native sets `UITabBarItem.badgeValue` | No (edits tab bar) |
| `LiquidGlassLabeledSwitch` | Pure Dart `Row(label + LiquidGlassSwitch)` | No |
| `LiquidGlassCheckbox` | SwiftUI checkbox-style toggle + glass | Yes |
| `LiquidGlassTextField` | Glass `UITextField` (focus, keyboard, placeholder, onChanged/onSubmitted) | Yes |

## Build order (one commit per step)

1. `LiquidGlassTheme` + wire resolution into existing widgets.
2. Accessibility helper in native glass views.
3. `LiquidGlassCard` + `LiquidGlassLabeledSwitch` (Dart-mostly).
4. `TabItem.badge`.
5. `LiquidGlassCheckbox`.
6. `LiquidGlassTextField`.

Each new widget ships with a gallery demo, dartdoc, and a non-iOS fallback.
Native Swift cannot be built/tested in this environment — each step is verified
by the maintainer with `flutter run`.

## Out of scope

Rich modal content, glass morph animations, Android shader fallback, wheel
picker, context menu — tracked separately.
