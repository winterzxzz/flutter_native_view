# Liquid Glass Flutter Plugin — Design

Date: 2026-06-24
Status: Approved (brainstorm)

## Goal

Reusable, clean, easy-to-use Flutter plugin that renders Apple **Liquid Glass**
(iOS 26 `glassEffect`) via native SwiftUI. Publishable to pub.dev.

## Decisions

| Topic | Decision |
| --- | --- |
| Artifact | Publishable Flutter **plugin package**. Current app → `example/`. |
| Components v1 | Generic glass **wrapper** + glass **button** (incl. heading variant) + native **switch**. |
| Render model | Hybrid: wrapper = "glass bg, Flutter child on top"; switch = fully native bridged SwiftUI `Toggle`. |
| Platforms | iOS-26-only, **hard**. Non-iOS / iOS<26 → plain tinted container, no crash in release; `assert` in debug. |
| Package name | `liquid_glass` (proposed; must be unique on pub.dev). |

## Package structure

```
liquid_glass/
├── lib/
│   ├── liquid_glass.dart            # public exports
│   └── src/
│       ├── glass_style.dart         # GlassStyle, GlassVariant
│       ├── liquid_glass.dart        # generic wrapper widget
│       ├── liquid_glass_button.dart # button + heading variant
│       ├── liquid_glass_switch.dart # native bridged switch
│       └── platform/
│           └── glass_surface_view.dart  # UiKitView for glass surface
├── ios/
│   ├── Classes/
│   │   ├── LiquidGlassPlugin.swift
│   │   ├── GlassViewFactory.swift
│   │   ├── GlassPlatformView.swift   # generic glass surface
│   │   └── GlassSwitchView.swift     # native SwiftUI Toggle
│   └── liquid_glass.podspec
├── example/                          # demo app (current app moves here)
└── pubspec.yaml                      # plugin: ios platform declared
```

## Dart public API

```dart
enum GlassVariant { regular, clear }

class GlassStyle {
  final Color? tint;
  final double cornerRadius;   // default 20
  final GlassVariant variant;  // default regular
  const GlassStyle({this.tint, this.cornerRadius = 20, this.variant = GlassVariant.regular});
}

// Generic wrapper — Stack: native glass surface fills behind, child on top.
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({required Widget child, GlassStyle style, EdgeInsets padding});
}

// Button — wrapper + Flutter GestureDetector (taps handled in Dart).
class LiquidGlassButton extends StatelessWidget {
  const LiquidGlassButton({required Widget child, required VoidCallback onPressed, GlassStyle style});
  const LiquidGlassButton.heading({...}); // prominent variant
}

// Switch — fully native SwiftUI Toggle, state bridged via MethodChannel.
class LiquidGlassSwitch extends StatefulWidget {
  const LiquidGlassSwitch({required bool value, required ValueChanged<bool> onChanged, Color? tint});
}
```

## Native architecture (iOS / Swift)

- `LiquidGlassPlugin.register` registers two `FlutterPlatformViewFactory`s:
  `liquid_glass/surface` and `liquid_glass/switch`.
- `GlassPlatformView` hosts `UIHostingController<GlassSurface>`; `GlassSurface`
  applies `.glassEffect(variant, in: .rect(cornerRadius:))` under
  `if #available(iOS 26.0, *)`, transparent background.
- `GlassSwitchView` hosts SwiftUI `Toggle`; per-view `MethodChannel`
  `liquid_glass/switch_<viewId>`. On toggle, native calls `invokeMethod("onChanged", bool)`.
  Dart→native `setValue` keeps state in sync.

## Fallback behavior

- Dart side: `assert(Platform.isIOS, 'LiquidGlass supports iOS 26+ only')` in debug.
- Release on non-iOS: render plain `Container` with optional `tint`, never crash.
- podspec `s.platform = :ios, '26.0'` + `#available` guard (belt-and-suspenders).

## Sizing

Wrapper uses `Stack` with `Positioned.fill` for the glass surface so the Flutter
child defines size; the native view fills behind it. Avoids platform-view
intrinsic-size problems.

## Testing

- Widget tests for Dart API construction + non-iOS fallback path.
- Native glass appearance verified manually on iOS 26 simulator (no automated
  native test in v1).

## Out of scope (v1, YAGNI)

- `GlassEffectContainer` morphing between shapes.
- Refracting Flutter pixels behind glass (hybrid composition).
- Android / web / macOS native glass.
- Interactive ripple effects beyond button press.
