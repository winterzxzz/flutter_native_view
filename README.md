# liquid_glass_native

Authentic SwiftUI Liquid Glass controls for Flutter.

`liquid_glass_native` embeds real native control content through `UiKitView`.
On iOS 26+, buttons use Apple's system glass button styles and custom controls
use `glassEffect` with native SwiftUI content. iOS 15–25 custom surfaces use
SwiftUI material fallbacks, and non-iOS platforms receive Material controls.

This is a native control library. It does not claim that an empty native glass
surface can authentically wrap an arbitrary Flutter widget tree.

## Requirements

- Flutter 3.41 / Dart 3.11 or newer.
- iOS deployment target 15.0 or newer.
- Xcode with the iOS 26 SDK to compile Liquid Glass symbols.
- An iOS 26 simulator or device to visually verify the actual material.

## Install

```yaml
dependencies:
  liquid_glass_native: ^1.0.0
```

```dart
import 'package:liquid_glass_native/liquid_glass_native.dart';
```

## Theme, style, and shape

The v1 interface has one immutable styling vocabulary:

```dart
LiquidGlassTheme(
  data: const LiquidGlassThemeData(
    style: LiquidGlassStyle(
      variant: LiquidGlassVariant.regular,
      tint: Color(0xFF0A84FF),
      shape: LiquidGlassShape.roundedRectangle(cornerRadius: 16),
      interactive: true,
    ),
    controlStyle: LiquidGlassControlStyle(
      tintColor: Color(0xFF0A84FF),
      foregroundColor: Colors.white,
      size: LiquidGlassControlSize.regular,
    ),
  ),
  child: MyApp(),
);
```

Mounted native controls update when the theme changes; they are not recreated.
Pass `style` to a glass-surfaced widget or `controlStyle` to any control to
replace its themed value. Use `copyWith` to derive a local variation; its
`clearTintColor`, `clearForegroundColor`, and `clearBrightness` flags remove
nullable values. Standard system controls intentionally do not accept
`LiquidGlassStyle`; their system accent belongs in
`LiquidGlassControlStyle.tintColor`.

Accessibility is always honored. Reduce Transparency uses a fully opaque
custom surface even if the tint has alpha below one, and Reduce Motion
suppresses explicitly interactive custom glass. System controls preserve their
native accessibility behavior.

## Buttons and symbols

`LiquidGlassSymbol` pairs an SF Symbol with a Material fallback icon:

```dart
LiquidGlassButton(
  label: 'Continue',
  leadingSymbol: const LiquidGlassSymbol(
    'arrow.right',
    fallbackIcon: Icons.arrow_forward,
  ),
  onPressed: () {},
);

LiquidGlassButton.prominent(label: 'Purchase', onPressed: () {});

LiquidGlassButton.icon(
  symbol: const LiquidGlassSymbol(
    'heart.fill',
    fallbackIcon: Icons.favorite,
  ),
  semanticLabel: 'Favorite',
  onPressed: () {},
);
```

Use one `LiquidGlassButtonGroup` for related actions. It owns one platform view
and one native `GlassEffectContainer`, rather than one platform view per button.

## Typed controls

```dart
LiquidGlassSwitch(
  value: enabled,
  controlStyle: const LiquidGlassControlStyle(tintColor: Colors.green),
  onChanged: (value) => setState(() => enabled = value),
);

LiquidGlassSlider(
  value: volume,
  min: 0,
  max: 1,
  onChanged: (value) => setState(() => volume = value),
);

LiquidGlassSegmentedControl<Period>(
  segments: const [
    LiquidGlassSegment(value: Period.day, label: 'Day'),
    LiquidGlassSegment(value: Period.week, label: 'Week'),
  ],
  value: period,
  onChanged: (value) => setState(() => period = value),
);
```

Retained v1 controls are:

- `LiquidGlassButton` and `LiquidGlassButtonGroup`
- `LiquidGlassSwitch` and `LiquidGlassCheckbox`
- `LiquidGlassSlider` and `LiquidGlassStepper`
- `LiquidGlassSegmentedControl<T>`
- `LiquidGlassTextField` and `LiquidGlassTextField.search`
- `LiquidGlassMenu<T>`
- `LiquidGlassDatePicker`
- `LiquidGlassColorPicker`

Callbacks may be null where disabling is meaningful. Constructors validate
ranges, bounds, selection membership, stable IDs, and other programmer
invariants before values cross the native boundary.

## Stable text input

Text fields use a persistent `TextEditingController` instead of recreating a
controller during `build`:

```dart
final controller = TextEditingController();

LiquidGlassTextField.search(
  controller: controller,
  placeholder: 'Search places',
  onSubmitted: search,
);
```

`LiquidGlassTextInputConfiguration` provides typed keyboard, capitalization,
submit-action, and one combined autocorrection/suggestion setting. SwiftUI 15
does not expose authoritative selection or composing ranges; native text edits
map the current Flutter ranges through the text delta instead of collapsing
them, while Dart-originated selection-only changes are not sent to native.

## Performance and diagnostics

Every standalone native control costs one platform view, one hosting
controller, and one per-view channel. Avoid large numbers of platform views in
recycling or rapidly scrolling lists. Prefer `LiquidGlassButtonGroup` for
related actions.

Deterministic traffic instrumentation is available without retaining payloads:

```dart
final diagnostics = LiquidGlassDiagnostics();

LiquidGlassTheme(
  data: const LiquidGlassThemeData(),
  diagnostics: diagnostics,
  child: const App(),
);

final snapshot = diagnostics.snapshot;
print(snapshot.configUpdates);
```

Equal nested snapshots send no update. Multiple changes in one Flutter frame
coalesce into at most one `updateConfig` call per view. A native value is
optimistically accepted before the callback: if the parent rebuilds with that
value, no echo is sent; if the callback rejects it or does not rebuild, the
authoritative Dart value is sent back after the frame.

These counters prove channel behavior only. They do not measure frame time,
GPU time, memory, energy, or visual correctness; use Instruments and an iOS 26
runtime for those claims.

## Migration from 0.1.x

v1 intentionally contains breaking changes:

| Pre-v1 | v1 |
| --- | --- |
| `LiquidGlassButton.heading` | `LiquidGlassButton.prominent` |
| `LiquidGlassIconButton` | `LiquidGlassButton.icon` |
| `GroupButton` / `buttons:` | `LiquidGlassButtonItem` / `items:` |
| `LiquidGlassSearchBar` | `LiquidGlassTextField.search` with a stable controller |
| `LiquidGlassTextField(text: value)` | a stable `controller:` for owned state, or `initialValue:` for initial text |
| date `min` / `max` / string `mode` | `minimumDate` / `maximumDate` / typed `LiquidGlassDatePickerComponents` |
| indexed string segments | `LiquidGlassSegment<T>` and a typed selected value |
| string-ID menu selections | `LiquidGlassMenuItem<T>` and typed values |
| `tint` on custom glass-surface controls | `LiquidGlassStyle.tint` |
| `tint` on switch/slider/stepper/segmented/date/color controls | `LiquidGlassControlStyle.tintColor` |
| `borderRadius` / `interactive` | `LiquidGlassStyle.shape` / `.interactive` on glass-surface controls only |
| foreground / brightness / semantic size | `LiquidGlassControlStyle` |
| text/slider `height`, switch `width`/`height`, checkbox `size` | `LiquidGlassControlStyle.size`; use `SizedBox` or other Flutter constraints for outer layout |

Standard system controls no longer accept a `style:` argument. This avoids
silently ignoring glass variant, shape, or interactivity on Apple controls
whose appearance is system-owned.

The following interfaces were retired rather than wrapped:

- `LiquidGlassContainer`, `LiquidGlassCard`, `LiquidGlassLabeledSwitch`
- `LiquidGlassActivityIndicator`, `LiquidGlassProgressView`
- `LiquidGlassNavigationBar`, `LiquidGlassTabBar`, `LiquidGlassToolbar`
- `LiquidGlassPresenter`, `LiquidGlassSheet`, `LiquidGlassAlert`,
  `LiquidGlassPopover`

Use Flutter layout/navigation/progress primitives for those roles. They were
removed because the old modules were shallow, hard-coded, expensive, or could
not satisfy an authentic native-content promise.

## Example and verification

```sh
cd example
flutter run
```

The example contains the v1 control gallery, live theme changes, diagnostics,
and the preserved weather sample. The repository's durable product, migration,
architecture, and validation records live under `docs/` and are intentionally
excluded from the pub.dev archive.
