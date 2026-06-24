# flutter_native_view

Native **SwiftUI Liquid Glass** widgets for Flutter. Controls are rendered by
SwiftUI and embedded via platform views, so on **iOS 26+** they use Apple's
authentic `glassEffect` material (interactive, with `GlassEffectContainer`).
Older iOS and other platforms fall back gracefully.

## Why native

Apple's Liquid Glass samples the real native render tree and reacts to touch.
Faking it with a Flutter `BackdropFilter` looks flat, because the glass needs to
wrap **real native content**. Here the label/switch are rendered natively, so the
material looks like the system glass. Concept follows
[native_liquid_glass](https://github.com/tienanh306201z/native_liquid_glass).

## Widgets

| Widget | Notes |
| --- | --- |
| `LiquidGlassActivityIndicator` | Native SwiftUI `ProgressView(.circular)`. Fixed size. |
| `LiquidGlassButton` / `.heading` | Native button; `label` rendered in SwiftUI. Auto-sizes via an intrinsic-size handshake. |
| `LiquidGlassContainer` | Decorative glass panel. Stack Flutter content on top. |
| `LiquidGlassProgressView` | Native linear `ProgressView`. Parent width, fixed height. |
| `LiquidGlassSwitch` | Native SwiftUI `Toggle`; state bridged back to Dart. |

## Usage

```dart
import 'package:flutter_native_view/flutter_native_view.dart';

LiquidGlassButton(
  label: 'Add',
  onPressed: () {},
  tint: Colors.blue,          // optional
  // borderRadius: 16,        // optional; capsule when null
);

LiquidGlassButton.heading(label: 'Glass Todos', onPressed: () {});

LiquidGlassSwitch(
  value: on,
  onChanged: (v) => setState(() => on = v),
);
```

## Platform behaviour

- **iOS 26+** — authentic Liquid Glass (`glassEffect(.regular.interactive())`).
- **iOS 16–25** — standard SwiftUI button / toggle styling.
- **iOS 14–15** — system controls.
- **Non-iOS** — Material `FilledButton` / `Switch` fallbacks.

## How it works

- Each widget is a `UiKitView`. The iOS plugin registers a
  `FlutterPlatformViewFactory` per control.
- A per-view `FlutterMethodChannel` (`<viewType>/<id>`) carries events
  (`onPressed`, `onChanged`) and updates (`updateConfig`, `setValue`).
- Buttons negotiate their size: native replies to `getIntrinsicSize`, and Flutter
  wraps the platform view in a matching `SizedBox`.

## Requirements

- Xcode with the **iOS 26 SDK** (to compile `glassEffect`, guarded by
  `#available`). The deployment target stays at 14.0.

## Run the example

```sh
cd example
flutter run
```

See `docs/superpowers/specs/2026-06-24-liquid-glass-plugin-design.md` for the
design history (native → Flutter shader → back to native).
