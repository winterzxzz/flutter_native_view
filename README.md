# liquid_glass_native

**Native Apple Liquid Glass UI for Flutter** — real SwiftUI/UIKit glass widgets,
not a `BackdropFilter` blur fake. Controls are rendered by SwiftUI and embedded
via platform views, so on **iOS 26+** they use Apple's authentic `glassEffect`
material (interactive, with `GlassEffectContainer`). Older iOS and other
platforms fall back gracefully.

> Keywords: liquid glass, iOS 26, SwiftUI, Cupertino, native platform view,
> glassmorphism, glass UI kit, Apple design.

## Why native

Apple's Liquid Glass samples the real native render tree and reacts to touch.
Faking it with a Flutter `BackdropFilter` looks flat, because the glass needs to
wrap **real native content**. Here the label/switch are rendered natively, so the
material looks like the system glass.

## Widgets

| Widget | Notes |
| --- | --- |
| `LiquidGlassActivityIndicator` | Native SwiftUI `ProgressView(.circular)`. Fixed size. |
| `LiquidGlassButton` / `.heading` | Native button; `label` rendered in SwiftUI. Auto-sizes via an intrinsic-size handshake. |
| `LiquidGlassButtonGroup` | Row of glass buttons sharing one `GlassEffectContainer`. |
| `LiquidGlassCard` | Glass surface with padding, rounded clip, and optional `onTap`. |
| `LiquidGlassCheckbox` | Native glass checkbox; shows a checkmark when checked. |
| `LiquidGlassColorPicker` | Native SwiftUI `ColorPicker`. Intrinsic size. |
| `LiquidGlassContainer` | Glass panel; pass a `child` to layer content on the glass. |
| `LiquidGlassDatePicker` | Native SwiftUI `DatePicker`. Intrinsic size, eager gesture. |
| `LiquidGlassIconButton` | Native icon-only glass button (SF Symbol). |
| `LiquidGlassLabeledSwitch` | A label + `LiquidGlassSwitch` setting row. |
| `LiquidGlassMenu` | Native pull-down menu button. |
| `LiquidGlassNavigationBar` | Native top bar with title + leading/trailing actions. |
| `LiquidGlassProgressView` | Native linear `ProgressView`. Parent width, fixed height. |
| `LiquidGlassSearchBar` | Native search field. Parent width, fixed height. |
| `LiquidGlassSegmentedControl` | Native segmented control. |
| `LiquidGlassSlider` | Native SwiftUI `Slider`. Parent width, fixed height, eager gesture. |
| `LiquidGlassStepper` | Native SwiftUI `Stepper`. Auto-sizes via intrinsic-size handshake. |
| `LiquidGlassSwitch` | Native SwiftUI `Toggle`; state bridged back to Dart. |
| `LiquidGlassTabBar` | Native tab bar; per-tab `badge`, search accessory, minimize-on-scroll. |
| `LiquidGlassTextField` | Native glass text input; placeholder, secure entry. |
| `LiquidGlassToolbar` | Native bottom toolbar with action buttons. |

Modals (`LiquidGlassSheet`, `LiquidGlassAlert`, `LiquidGlassPopover`) are
presented natively via the shared presenter.

## Theming & accessibility

Wrap your app in a `LiquidGlassTheme` to set app-wide defaults; each widget
resolves a value as **explicit param ?? theme ?? built-in default**:

```dart
LiquidGlassTheme(
  data: const LiquidGlassThemeData(tint: Color(0xFF0A84FF), borderRadius: 16),
  child: MyApp(),
);
```

When `respectAccessibility` is on (the default), native glass honors the system
*Reduce Transparency* (opaque surface) and *Reduce Motion* (no interactive
touch response) settings.

## Usage

```dart
import 'package:liquid_glass_native/liquid_glass_native.dart';

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
