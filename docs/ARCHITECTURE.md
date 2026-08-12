# Flutter Plugin Architecture

This repository is a Flutter plugin with native Apple Liquid Glass widgets.
The repository's product architecture, not the generic Harness core, is the
authority for implementation shape.

## Layers

```text
Dart public widgets
  -> UiKitView platform-view bridge
    -> per-view FlutterMethodChannel
      -> Swift platform-view factory
        -> SwiftUI/UIKit control
```

Non-iOS platforms use the documented Flutter/Material fallback widgets.

## Widget Boundary

Each widget has a Dart implementation under `lib/src/` and a corresponding
native implementation under `ios/Classes/`. A widget typically communicates
through a channel named `<viewType>/<id>` with messages such as:

- `getIntrinsicSize` for controls whose native content determines size;
- `updateConfig` for visual and behavioral configuration;
- `setValue` for controlled state; and
- `onPressed` or `onChanged` for native events.

The public Dart API is exported from `lib/liquid_glass_native.dart`. Native
factories are registered in `ios/Classes/FlutterNativeViewPlugin.swift`.

## Platform Behavior

- iOS 26+ uses SwiftUI `glassEffect` where available.
- iOS 14-25 use standard SwiftUI/UIKit controls and styling.
- Non-iOS platforms use the package's Material fallbacks.

The deployment target remains iOS 14.0; compiling authentic Liquid Glass
requires an Xcode installation with the iOS 26 SDK.

## Change Shape

When adding a widget, update the Dart widget, native Swift view and factory,
plugin registration, public export, and widget tests together. Preserve the
method-channel lifecycle and intrinsic-size handshake used by neighboring
widgets.

## Proof

Use the commands in the root `README.md`:

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `cd example && flutter run` for iOS runtime proof when native behavior is in
  scope.
