# Architecture

## Selected Stack

- Product surface: publishable Flutter plugin plus Flutter example app.
- Dart: Flutter 3.41 / Dart 3.11.
- Native adapter: Swift 5.9, SwiftUI/UIKit, CocoaPods.
- Native deployment: iOS 15+, with iOS 26 Liquid Glass availability gates.
- Durable Harness records: worktree-local SQLite managed by Harness CLI.

## Module Shape

The package is a deep native-control module. Callers learn immutable style
types and named Flutter widgets. Platform view construction, serialization,
channel synchronization, unknown native payload parsing, hosting, measurement,
availability, and teardown remain behind that interface.

```text
public Dart value types and widgets
  -> private Dart bridge snapshot/lifecycle
    -> Flutter platform-view seam
      -> shared Swift parser/host/style infrastructure
        -> typed native control model and SwiftUI view
```

The seam has two adapters:

- iOS adapter: `UiKitView` plus SwiftUI native controls.
- non-iOS adapter: Flutter Material controls.

Customization has two honest capability levels:

- Custom glass-surface controls serialize `LiquidGlassStyle` and
  `LiquidGlassControlStyle`.
- Standard system controls serialize only `LiquidGlassControlStyle`; their
  accent is `tintColor`, and Apple owns their shape/material behavior.

## Dependency Rule

- Public widgets may depend on public value types and private Dart bridge code.
- Public value types do not depend on platform channels.
- Private Dart bridge code knows serialized field names; callers do not.
- Swift control models consume `GlassArguments`, never raw channel maps.
- Control files depend on shared Swift infrastructure; shared infrastructure
  never depends on one specific control.

## Boundary Contract

Unknown `FlutterStandardMessageCodec` data is parsed by `GlassArguments` before
it enters a control configuration. Numbers accept `NSNumber` and are clamped or
defaulted. Public Dart constructors validate programmer-controlled invariants
before serialization.

## Lifecycle And Observability

`GlassPlatformViewMixin` owns Dart channel setup and disposal.
`GlassPlatformViewHost` owns the native channel, hosting controller, view,
measurement, and teardown. Optional `LiquidGlassDiagnostics` counts operations
without payloads. See decision `0009-synchronized-platform-view-bridge.md`.

Controlled native values are optimistic only until the callback frame. The
tracker suppresses accepted-value echoes but sends the original Dart value back
when the callback rejects or omits a rebuild. See decision
`0010-controlled-state-and-capability-contract.md`.

## Security And Privacy

- No dynamic code execution, shell, network, file, or persistence sinks exist.
- No credentials cross the bridge.
- Text input values cross the per-view channel by design but are never logged or
  retained by diagnostics.
- Invalid bridge fields fail closed to validated defaults or disabled behavior.
