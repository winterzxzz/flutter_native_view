# Migrating To liquid_glass_native 1.0

Version 1.0 intentionally removes the broad pre-v1 surface instead of carrying
compatibility wrappers for APIs that were unauthentic, weakly typed, or
platform-inconsistent.

## Platform Requirement

Raise the consuming iOS deployment target from 14.0 to 15.0.

## Styling

Use glass material configuration only on controls that own a custom glass
surface:

```dart
const LiquidGlassStyle(
  tint: Color(0xFF0A84FF),
  shape: LiquidGlassShape.roundedRectangle(cornerRadius: 16),
);
```

Standard system controls—switch, slider, stepper, segmented control, date
picker, and color picker—no longer accept `style:`. Move their old `tint` to:

```dart
const LiquidGlassControlStyle(tintColor: Color(0xFF0A84FF));
```

`LiquidGlassControlStyle.copyWith` retains nullable values by default. Use
`clearTintColor`, `clearForegroundColor`, or `clearBrightness` to remove one.

## Text Input

Pre-v1 controlled text:

```dart
LiquidGlassTextField(text: query, onChanged: updateQuery);
```

Use a stable controller when the caller owns ongoing text state:

```dart
final queryController = TextEditingController(text: query);

LiquidGlassTextField(
  controller: queryController,
  onChanged: updateQuery,
);
```

For initial text that the field may subsequently own, use `initialValue:`.
`LiquidGlassSearchBar` becomes `LiquidGlassTextField.search`.

The old `height` parameter is removed. Choose a semantic
`LiquidGlassControlSize` and use Flutter layout constraints for outer sizing.
Autocorrection and suggestions are one `autocorrect` capability because
SwiftUI does not expose them independently across every supported iOS version.

## Date Picker

| Pre-v1 | v1 |
| --- | --- |
| `min` | `minimumDate` |
| `max` | `maximumDate` |
| `mode: 'date'` | `components: LiquidGlassDatePickerComponents.date` |
| `mode: 'time'` | `components: LiquidGlassDatePickerComponents.time` |
| `mode: 'dateAndTime'` | `components: LiquidGlassDatePickerComponents.dateAndTime` |

The cross-platform supported calendar range is year 1 through 9999. Unbounded
Material dialogs derive safe limits around the current value instead of using
product-specific 1900/2200 defaults.

## Typed Selection

- Replace string segments plus `selectedIndex` with
  `LiquidGlassSegmentedControl<T>`, `LiquidGlassSegment<T>`, and a typed
  selected `value`.
- Replace string-ID menu selection with `LiquidGlassMenuItem<T>` and typed
  callback values.

## Removed Numeric Dimensions

| Pre-v1 parameter | Replacement |
| --- | --- |
| switch `width` / `height` | `LiquidGlassControlStyle.size` |
| slider `height` | `LiquidGlassControlStyle.size` |
| checkbox `size` | `LiquidGlassControlStyle.size` |
| text field `height` | `LiquidGlassControlStyle.size` |
| button `borderRadius` | `LiquidGlassStyle.shape` |

Use `SizedBox`, `ConstrainedBox`, or normal parent layout when the outer Flutter
slot needs a specific size. Semantic size configures the native and Material
control itself.

## Renamed Or Retired Interfaces

- `LiquidGlassButton.heading` becomes `LiquidGlassButton.prominent`.
- `LiquidGlassIconButton` becomes `LiquidGlassButton.icon`.
- `GroupButton` / `buttons:` become `LiquidGlassButtonItem` / `items:`.
- Container, card, labeled switch, progress/activity, navigation/tab/toolbar,
  and fixed-content presenter APIs are removed. Use Flutter primitives for
  those roles; arbitrary Flutter children are not presented as authentic
  SwiftUI Liquid Glass.
