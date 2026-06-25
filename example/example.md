# liquid_glass_native examples

Native Apple Liquid Glass widgets for Flutter. Every widget renders through
SwiftUI/UIKit (authentic `glassEffect` on iOS 26+) and falls back to Material
on other platforms.

```dart
import 'package:liquid_glass_native/liquid_glass_native.dart';
```

The example app in this directory is a full gallery of every widget — run it
with `cd example && flutter run`. The snippets below show the most common ones.

## Buttons

```dart
LiquidGlassButton(
  label: 'Add to cart',
  onPressed: () {},
  tint: Colors.blue,        // optional glass tint
  leadingSymbol: 'cart',    // optional SF Symbol
);

// Larger, more prominent variant.
LiquidGlassButton.heading(label: 'Get Started', onPressed: () {});

// Icon-only circular button.
LiquidGlassIconButton(sfSymbol: 'heart.fill', onPressed: () {});
```

## Controls

```dart
LiquidGlassSwitch(
  value: isOn,
  onChanged: (v) => setState(() => isOn = v),
);

LiquidGlassSlider(
  value: volume,            // 0.0 ... 1.0
  onChanged: (v) => setState(() => volume = v),
);

LiquidGlassStepper(
  value: count,
  min: 0,
  max: 10,
  onChanged: (v) => setState(() => count = v),
);

LiquidGlassSegmentedControl(
  segments: const ['Day', 'Week', 'Month'],
  selectedIndex: selected,
  onChanged: (i) => setState(() => selected = i),
);
```

## Glass panel

Wrap any Flutter content in a native glass surface:

```dart
LiquidGlassContainer(
  tint: const Color(0xFF6C63FF),
  borderRadius: 16,
  child: const Padding(
    padding: EdgeInsets.all(20),
    child: Text('Framed in glass', style: TextStyle(color: Colors.white)),
  ),
);
```

## Bars

```dart
LiquidGlassNavigationBar(
  title: 'Inbox',
  trailing: [
    BarAction(id: 'compose', sfSymbol: 'square.and.pencil', onPressed: () {}),
  ],
);

LiquidGlassTabBar(
  items: const [
    TabItem(label: 'Home', sfSymbol: 'house'),
    TabItem(label: 'Library', sfSymbol: 'books.vertical'),
  ],
  currentIndex: index,
  onTap: (i) => setState(() => index = i),
  // A detached glass search button beside the tabs.
  accessorySymbol: 'magnifyingglass',
  onAccessoryTap: () => LiquidGlassSheet.show(context: context, title: 'Search'),
);
```

## Modals

Static presenters — call them from any event handler:

```dart
// Bottom sheet.
await LiquidGlassSheet.show(context: context, title: 'Details');

// Alert with actions; returns the tapped button's id.
final id = await LiquidGlassAlert.show(
  context: context,
  title: 'Delete file?',
  message: 'This cannot be undone.',
  buttons: const [
    AlertButton(id: 'cancel', label: 'Cancel'),
    AlertButton(id: 'delete', label: 'Delete', destructive: true),
  ],
);

// Popover.
await LiquidGlassPopover.show(context: context, title: 'Info');
```
