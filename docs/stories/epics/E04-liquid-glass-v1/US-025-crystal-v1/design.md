# Design

## Domain Model

The stable product types are glass variant, shape, custom-surface style,
standard control style, symbols, typed selectable items, text-input
configuration, and diagnostics snapshots. All are immutable value objects.
Widgets validate their own invariants before serialization.

## Application Flow

1. A custom-surface widget resolves glass and control style; a standard system
   control resolves control style only. Each builds one private snapshot.
2. The platform view receives that snapshot at creation.
3. Widget/theme/controller changes are deep-compared and coalesced into one
   atomic `updateConfig` snapshot.
4. Swift parses unknown payloads through `GlassArguments`, updates the
   observable model, and returns a new intrinsic size only when needed.
5. Native events optimistically patch Dart's last-known snapshot before
   invoking the caller and schedule a post-frame reconciliation. Accepted
   rebuilds do not echo; rejected events are reverted to Dart state.

## Interface Contract

The public interface is defined in `docs/product/liquid-glass-v1.md`. The
private per-view channel supports:

- `getIntrinsicSize -> {width, height}`
- `updateConfig(Map) -> {width, height}?`
- native events using specific names (`onPressed`, `onChanged`, `onSubmitted`,
  `onSelected`) and scalar index/value payloads.

Unknown native calls return `FlutterMethodNotImplemented`. Invalid public
constructor states fail with Dart assertions; invalid bridge fields fail closed
to validated defaults or the previous model value.

## Data Model

No persistent data or migration exists. Method-channel snapshots are ephemeral
and contain no credentials. Diagnostics record counts and view type only, never
text or other payload values.

## UI / Platform Impact

- iOS deployment target becomes 15.0.
- iOS 26 uses native Liquid Glass style/effects behind availability checks.
- iOS 15–25 use SwiftUI materials for custom surfaces and native styles for
  standard controls.
- Non-iOS uses Material fallbacks with stable controllers and equivalent value
  callbacks.
- Each standalone retained control owns one platform view; button groups own
  one platform view for the whole group.

## Observability

`LiquidGlassDiagnostics` exposes created-view, outbound-update, native-event,
and intrinsic-measurement counts. Tests assert traffic behavior. No payload is
logged.

## Alternatives Considered

1. Compatibility wrappers around pre-v1 names: rejected because they preserve
   weak promises and duplicate configuration systems.
2. One global channel: rejected because instance lifecycle and event locality
   are clearer with per-view channels.
3. One generic public control: rejected because named widgets are more
   discoverable and support stronger constructor invariants.
