# flutter_native_view

Liquid Glass widgets for Flutter. **Pure Dart** — rendered with `BackdropFilter`,
so the glass blurs and tints whatever is painted behind it and works on **every
platform** Flutter supports (iOS, Android, macOS, web, Windows, Linux). No native
code, no iOS 26 requirement.

> Design language inspired by Apple's Liquid Glass. This is a Flutter emulation,
> not the native iOS material.

## Widgets

| Widget | What it does |
| --- | --- |
| `LiquidGlass` | Wraps any child in a frosted glass surface. |
| `LiquidGlassButton` / `.heading` | Tappable glass button with a press animation. |
| `LiquidGlassSwitch` | Animated glass toggle switch. |
| `GlassBox` | Low-level glass surface, if you want to build your own. |

## Usage

```dart
import 'package:flutter_native_view/flutter_native_view.dart';

// Generic wrapper
LiquidGlass(
  style: const GlassStyle(cornerRadius: 24),
  child: const Text('Any widget, wrapped'),
);

// Button
LiquidGlassButton(
  onPressed: () {},
  child: const Text('Tap me'),
);

// Prominent heading button
LiquidGlassButton.heading(
  onPressed: () {},
  child: const Text('Liquid Glass'),
);

// Toggle
LiquidGlassSwitch(
  value: on,
  onChanged: (v) => setState(() => on = v),
);
```

## Styling

`GlassStyle(tint, cornerRadius, variant, blurSigma)`:

- `tint` — overlay color (defaults to white).
- `cornerRadius` — rounded shape radius.
- `variant` — `GlassVariant.regular` (frosted) or `GlassVariant.clear` (more translucent).
- `blurSigma` — Gaussian blur strength of the backdrop.

## Tip

The glass only looks like glass when there is something behind it. Place these
widgets over a colorful background, an image, or scrolling content.

## Run the example

```sh
cd example
flutter run
```

See `docs/superpowers/specs/2026-06-24-liquid-glass-plugin-design.md` for the
original design and the rationale for moving from native SwiftUI to a pure
Flutter implementation.
