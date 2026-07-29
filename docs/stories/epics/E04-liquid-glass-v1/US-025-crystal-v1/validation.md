# Validation

## Proof Strategy

Prove public invariants and bridge deduplication with deterministic Dart tests,
prove non-iOS behavior with widget tests, and compile the real Swift plugin with
the equipped iOS 26 SDK. Clearly separate compilation and traffic counts from
visual or runtime performance claims.

## Test Plan

| Layer | Cases |
| --- | --- |
| Unit | nullable style clearing, shape/range validation, text range mapping, deep snapshot equality, accepted echo suppression, rejected-value correction for all controlled families |
| Integration | real channel reconciliation, Material size/tint/date boundaries, stable text controller, callbacks, theme inheritance, retired export absence through analysis |
| E2E | Example app builds against the v1 interface |
| Platform | CocoaPods/Xcode or Flutter iOS simulator build compiles all Swift availability paths |
| Performance | equal nested snapshots send zero updates; multiple same-frame changes coalesce; accepted events do not echo; rejected events send one required correction |
| Logs/Audit | diagnostics count metadata only; no value payloads are retained |

## Fixtures

- Two and three-item generic segment/menu lists.
- Controlled switch, slider, text, date, and color values.
- Theme changes that alter style and control style after a native view exists.
- Fake snapshots with nested lists/maps for structural equality.

## Commands

```text
dart format lib test example/lib example/test
flutter analyze
flutter test
cd example && flutter test
cd example && flutter build ios --simulator --debug
```

## Acceptance Evidence

The independent review rejected the 2026-07-29 checkpoint and invalidated its
proof. Replacement evidence is recorded in
`docs/validation/2026-07-30-us-025-review-remediation.md` after the complete
format, analysis, test, iOS build, package, diff, and Harness rerun.

Observed replacement results: format 60 files/0 changes, clean analysis, 37
root tests, 68 example tests, successful iOS Simulator build, clean diff check,
and an 84 KB qualified publish archive. Harness story and decision verification
commands both passed with clean analysis and 37/37 root tests.

Durable story `US-025` uses `flutter analyze && flutter test` as its mechanical
verification command. Interactive E2E, Instruments, and visual/accessibility
runtime checks remain unclaimed.
