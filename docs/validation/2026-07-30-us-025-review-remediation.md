# Validation Report: US-025 Independent Review Remediation

Date: 2026-07-30

## Scope

This report supersedes the rejected 2026-07-29 checkpoint. It validates every
evidence-backed independent review finding: controlled-value rejection,
accessibility opacity, older-iOS material, text editing semantics, date bounds,
customization capability truthfulness, migration completeness, and nullable
style clearing.

## Finding Resolution

| Finding | Resolution | Regression proof |
| --- | --- | --- |
| Rejected native values remained changed | Shared `dispatchControlledNativeState` patches optimistically, invokes the callback, and schedules post-frame reconciliation in `finally` | Real mock method-channel tests prove accepted events send zero updates and rejected events send exactly one correction; parameterized tracker cases cover switch, checkbox, slider, stepper, segmented, date, and color values |
| Reduce Transparency could preserve tint alpha | Swift forces `withAlphaComponent(1)` before drawing the custom fallback | Native source contract test plus successful Swift/iOS build |
| iOS 15–25 used a low-alpha color | Custom surfaces now fill their shape with SwiftUI `ultraThinMaterial` and overlay optional tint | Native source contract test plus successful Swift/iOS build |
| Text selection/composing collapsed; suggestion traits were merged silently | Native text changes map Flutter selection/composing through the text delta; public configuration exposes one documented `autocorrect` capability | Two editing-range unit tests; Swift source contract proves there is no independent `enableSuggestions` field |
| Material date defaults asserted outside 1900–2200 | Public range is year 1–9999; unbounded dialogs derive clamped value-relative limits | Widget tests open date dialogs for years 1800 and 2300; constructor rejects year 10000 |
| Shared customization contained silent no-ops | `LiquidGlassStyle` is limited to custom-surface controls; standard controls accept `LiquidGlassControlStyle.tintColor` only. Shared fallback infrastructure applies tint, semantic size, foreground, brightness, and disabled opacity | Swift source test rejects glass parsing in six standard controls; widget tests cover switch size, color tint, brightness, and disabled opacity |
| Color-picker opacity was an adjacent fallback mismatch | Material picker now conditionally exposes an opacity slider and preserves/forces alpha according to `supportsOpacity` | Widget tests cover both capability states |
| Migration gaps | README, changelog, example, and `docs/MIGRATION_V1.md` map text state, date names/components, tint split, numeric dimensions, typed selection, and retired interfaces | Analysis compiles the migrated gallery and weather example |
| Nullable values could not be cleared through `copyWith` | Added typed `clearTintColor`, `clearForegroundColor`, and `clearBrightness` flags | Value-object unit assertions |

## Commands And Results

```text
dart format --output=none --set-exit-if-changed lib test example/lib example/test
flutter analyze
flutter test
cd example && flutter test
cd example && flutter build ios --simulator --debug
flutter pub publish --dry-run
git diff --check
```

| Check | Observed result |
| --- | --- |
| Format | pass; 60 files checked, 0 changes |
| Analyze | pass; no issues |
| Root unit/widget/source contracts | pass; 37/37 |
| Example regression | pass; 68/68 |
| iOS platform compile | pass; Xcode build 11.9s; produced `example/build/ios/iphonesimulator/Runner.app` |
| Toolchain | Xcode 26.3 (17C529), iOS Simulator SDK 26.2, Swift 6.2.4 |
| Diff whitespace | pass |
| Publish archive | qualified; 84 KB compressed and free of build, Pods, ephemeral, Harness, and handoff artifacts |
| Harness story verification | pass; `US-025` reran clean analysis and 37/37 tests |
| Harness decision verification | pass; `0010-controlled-state-and-capability-contract` reran clean analysis and 37/37 tests |
| Harness detailed trace | pass; remediation trace `3` achieved detailed `3/3` and context `3/3` |

The publish dry-run exits 65 only on two unavoidable Git-state warnings: the
breaking removals are still tracked until a commit records them, and the task
explicitly requires an uncommitted working tree. The archive was fully built
and validated before those warnings.

## Deterministic Traffic Evidence

- Structurally equal snapshots produce zero outbound updates.
- Multiple scheduling requests in one frame enqueue one flush.
- Accepted native values followed by a parent rebuild produce zero echo.
- Rejected native values produce exactly one authoritative `updateConfig`.
- Rejected cases cover every controlled value family named by the review.
- Snapshot freezing, asynchronous creation catch-up, intrinsic revision guards,
  and native-iOS platform selection remain covered.

The rejected-value update is required correctness traffic, not redundancy.
Diagnostics remain payload-free.

## Honest Limits

- The Swift source-contract tests and iOS build prove policy presence and
  compilation, not rendered opacity/material pixels.
- No interactive iOS 26 runtime session observed VoiceOver, Dynamic Type,
  Reduce Transparency, Reduce Motion, touch arbitration, or native rejection
  animations.
- No Instruments run measured frame time, GPU, memory, energy, or large-list
  platform-view behavior.
- Interactive E2E proof remains unset.
- Harness still has no registered provider for impact analysis, coverage,
  security scanning, performance benchmarking, or documentation lookup.
