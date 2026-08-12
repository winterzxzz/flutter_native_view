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

Start with the requested outcome, then use the repository as the system of
record. Read `docs/WORKFLOW.md` and only relevant product, design, plan, code,
and validation material.

- Answers, explanations, reviews, diagnoses, plans, and status reports are
  read-only. Inspect only what is needed and do not mutate repository or Harness
  state.
- For a bounded change, use an ephemeral plan: inspect the affected behavior and
  proof, implement, and validate. No control-plane operation is required.
- Create or update one file under `docs/plans/active/` when work spans sessions,
  needs coordination, has meaningful dependencies, or requires recovery steps.
  Move it to `docs/plans/completed/` only after validation.
- Before editing, identify repository authority for each new externally
  observable policy. If materially different choices remain open, stop before
  edits; configurable defaults are not authority.
- Report reusable agent friction. Change guidance, tools, runbooks, or validation
  for that purpose only when explicitly asked to use `$improve-harness`.
- Also pause when product intent remains ambiguous, recovery is difficult,
  validation is weakened, or authority is insufficient.
- Claim completion only with relevant executable or observable evidence. Report
  the outcome, important changes, validation, and unresolved risks.

Harness has no task database or orchestration lifecycle. Use repository-owned
plans and behavior-level proof; do not create parallel control-plane state.
<!-- HARNESS:END -->
