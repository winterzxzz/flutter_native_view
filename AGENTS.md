# Repository Guidelines

A Flutter plugin providing native Apple Liquid Glass UI widgets via SwiftUI platform views.

## Project Structure

```
lib/
  liquid_glass_native.dart    # Main export file
  src/                        # Dart widget implementations (28 files)
ios/
  Classes/                    # Swift platform view implementations (22 files)
  liquid_glass_native.podspec
example/                      # Example app demonstrating widgets
test/                         # Widget tests
```

## Build, Test, and Development Commands

- `flutter pub get` — Install Dart dependencies
- `flutter analyze` — Run static analysis with flutter_lints
- `flutter test` — Run widget tests in `test/`
- `cd example && flutter run` — Run the example app on iOS device/simulator

## Coding Style

- **Dart**: Follows `package:flutter_lints/flutter.yaml` rules
- **Swift**: Standard Swift naming; each widget has a corresponding `Glass*View.swift` file
- **Naming**: Widgets prefixed with `LiquidGlass*` in Dart, `Glass*View` in Swift

## Architecture

- Each widget is a `UiKitView` with a per-view `FlutterMethodChannel` (`<viewType>/<id>`)
- Communication: `getIntrinsicSize`, `updateConfig`, `setValue`, events (`onPressed`, `onChanged`)
- Platform behavior: iOS 26+ uses authentic `glassEffect`; iOS 14-25 uses standard SwiftUI; non-iOS uses Material fallbacks

## Widget Implementation Pattern

When adding a new widget:

1. Create `lib/src/liquid_glass_<widget>.dart` — Dart widget extending stateful/stateless
2. Create `ios/Classes/Glass<Widget>View.swift` — SwiftUI view with `FlutterPlatformViewFactory`
3. Register in `ios/Classes/FlutterNativeViewPlugin.swift`
4. Export from `lib/liquid_glass_native.dart`
5. Add test in `test/widgets_test.dart`

## Requirements

- Xcode with **iOS 26 SDK** for `glassEffect` compilation
- Deployment target: iOS 14.0+

<!-- HARNESS:BEGIN -->
## Harness

This repo uses Harness. Before work, read:

- `README.md`
- `docs/HARNESS.md`
- `docs/FEATURE_INTAKE.md`
- `docs/ARCHITECTURE.md`
- `docs/CONTEXT_RULES.md`
- `docs/TOOL_REGISTRY.md`
- `scripts/bin/harness-cli query matrix` on macOS/Linux, or `.\scripts\bin\harness-cli.exe query matrix` on Windows

Use the Rust Harness CLI at `scripts/bin/harness-cli` on macOS/Linux or
`scripts/bin/harness-cli.exe` on Windows as the main operational tool. Before a
step that could use an external tool, run `scripts/bin/harness-cli query tools
--capability <name> --status present` to see what is equipped; an absent
capability is a clean skip.
<!-- HARNESS:END -->
