# flutter_native_view

Liquid Glass widgets for Flutter, rendered by **native SwiftUI** (`glassEffect`)
on **iOS 26+**.

## Widgets

| Widget | What it does |
| --- | --- |
| `LiquidGlass` | Wraps any child in a native glass surface (glass behind, Flutter content on top). |
| `LiquidGlassButton` / `.heading` | Tappable glass button; tap handled in Flutter, label is any widget. |
| `LiquidGlassSwitch` | Fully native SwiftUI `Toggle` with glass; value bridged back to Dart. |

## Usage

```dart
import 'package:flutter_native_view/flutter_native_view.dart';

// Generic wrapper
LiquidGlass(
  style: const GlassStyle(cornerRadius: 24, tint: Colors.white),
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

// Native switch
LiquidGlassSwitch(
  value: on,
  onChanged: (v) => setState(() => on = v),
);
```

## Styling

`GlassStyle(tint, cornerRadius, variant)` — `variant` is `GlassVariant.regular`
or `GlassVariant.clear`. Maps to Apple's `Glass` styles.

## Platform support

- **iOS 26+** — native Liquid Glass via SwiftUI `glassEffect`.
- **iOS < 26** — frosted `.ultraThinMaterial` fallback (native).
- **Other platforms** — plain tinted container so layouts never break. Building
  `LiquidGlass` off iOS trips a debug `assert`; release renders the fallback.

### Requirements

- Xcode with the **iOS 26 SDK** (the plugin compiles `glassEffect`, an iOS 26 API).
- iOS deployment target **26.0** (set in `ios/flutter_native_view.podspec`).

## Run the example

```sh
cd example
flutter run
```

## Design notes

- The glass surface is a decorative `UiKitView` that forwards all gestures to
  Flutter (empty `gestureRecognizers`), so the child receives taps.
- The switch claims gestures (`EagerGestureRecognizer`) because the native
  `Toggle` is the interactive element; its state is synced over a per-view
  `MethodChannel` (`flutter_native_view/glass_switch_<id>`).
- Glass refracts whatever the **native** layer renders behind it. Refracting the
  Flutter UI behind the glass (hybrid composition) is out of scope for now.

See `docs/superpowers/specs/2026-06-24-liquid-glass-plugin-design.md` for the
full design.
