# liquid_glass_native v1 examples

```dart
import 'package:liquid_glass_native/liquid_glass_native.dart';
```

## Theme

```dart
LiquidGlassTheme(
  data: const LiquidGlassThemeData(
    style: LiquidGlassStyle(
      tint: Color(0xFF6C63FF),
      shape: LiquidGlassShape.roundedRectangle(cornerRadius: 16),
    ),
    controlStyle: LiquidGlassControlStyle(
      tintColor: Color(0xFF6C63FF),
      foregroundColor: Colors.white,
    ),
  ),
  child: const App(),
);
```

Theme changes synchronize to mounted native controls.

## Buttons

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

## Typed selection

```dart
enum Period { day, week }

LiquidGlassSegmentedControl<Period>(
  segments: const [
    LiquidGlassSegment(value: Period.day, label: 'Day'),
    LiquidGlassSegment(value: Period.week, label: 'Week'),
  ],
  value: period,
  onChanged: (value) => setState(() => period = value),
);
```

## Stable search input

```dart
final searchController = TextEditingController();

LiquidGlassTextField.search(
  controller: searchController,
  placeholder: 'Search places',
  onSubmitted: search,
);
```

Run the full gallery with `cd example && flutter run`.
