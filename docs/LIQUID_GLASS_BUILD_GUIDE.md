# Liquid Glass Widgets — Implementation Guide

Authoritative build guide for implementing the full native Liquid Glass widget
set in `flutter_native_view`. Written so multiple agents can work in parallel
without colliding.

---

## 0. Ground rules (read first)

1. **Original code only.** You may study the *concepts* of public packages
   (e.g. `native_liquid_glass`, `liquid_glass_widgets`) for inspiration, but you
   must **never copy their source**. This package will be published; all code
   must be ours. When in doubt, implement from the SwiftUI/UIKit Apple docs and
   the canonical pattern in §5.
2. **Follow the established pattern.** `LiquidGlassButton`
   (`lib/src/liquid_glass_button.dart` + `ios/Classes/GlassButtonView.swift`) and
   `LiquidGlassSwitch` are the reference implementations. Match their structure,
   naming, and channel protocol exactly.
3. **One widget = isolated files.** Each widget owns its own Dart file and Swift
   file. The only shared edits are: one export line, one factory registration
   line, and one example demo entry. §8 defines how to avoid merge conflicts.
4. **Every widget ships with:** clean `flutter analyze`, a fallback widget test,
   a successful iOS-simulator build, an example demo entry, and a README row.
5. **iOS 26 is the target for real glass.** Lower tiers degrade (see §4). Never
   crash on any platform.

---

## 1. Architecture overview

```
Flutter (Dart)                       iOS (Swift)
┌────────────────────┐               ┌──────────────────────────────┐
│ LiquidGlass<Name>  │  UiKitView    │ Glass<Name>ViewFactory        │
│ (StatefulWidget)   │──────────────▶│  → Glass<Name>PlatformView    │
│                    │               │     ├─ UIView container        │
│  creationParams ───┼──── args ────▶│     ├─ UIHostingController     │
│                    │               │     │   └─ Glass<Name>Root (SwiftUI)
│  MethodChannel ◀───┼── events ─────┤     └─ Glass<Name>Model (ObservableObject)
│   "<viewType>/<id>"│── methods ───▶│         (channel handler)      │
└────────────────────┘               └──────────────────────────────┘
```

- Each widget is a **platform view** (`UiKitView`) backed by a SwiftUI view in a
  `UIHostingController`.
- State and events flow over a **per-view `FlutterMethodChannel`** named
  `"<viewType>/<viewId>"`.
- A widget's native side owns an `ObservableObject` **model**; the SwiftUI root
  observes it so `updateConfig`/`setValue` re-render reactively.

---

## 2. Naming & file conventions

For a widget named `Foo`:

| Thing | Value |
| --- | --- |
| Dart class | `LiquidGlassFoo` |
| Dart file | `lib/src/liquid_glass_foo.dart` |
| Swift file | `ios/Classes/GlassFooView.swift` |
| Swift types | `GlassFooViewFactory`, `GlassFooPlatformView`, `GlassFooModel`, `GlassFooRoot` |
| viewType id | `flutter_native_view/glass_foo` |
| Channel name | `flutter_native_view/glass_foo/<viewId>` |

- Export the Dart class from `lib/liquid_glass_native.dart`.
- Register the factory in `ios/Classes/FlutterNativeViewPlugin.swift`.
- Colors cross the boundary as **ARGB32 ints**: Dart `color.toARGB32()` →
  Swift `GlassColor.fromARGB(_:)` (already exists in `ios/Classes/GlassColor.swift`).
- Keep one widget entirely in its two files. Shared helpers go in their own file
  (e.g. `GlassColor.swift`); do not bloat a widget file with reusable code.

---

## 3. Channel protocol

### Dart → Native (method calls)

| Method | Args | Returns | Used by |
| --- | --- | --- | --- |
| `getIntrinsicSize` | none | `{width: double, height: double}` | content-sized widgets (button, etc.) |
| `updateConfig` | full params map | `{width, height}` | any widget whose config can change |
| `setValue` | the new value | `null` | value widgets (toggle, slider, stepper) |

Add widget-specific methods only when necessary; prefer `updateConfig` for
config changes.

### Native → Dart (events)

| Method | Args | Meaning |
| --- | --- | --- |
| `onPressed` | none | button tapped |
| `onChanged` | new value | value changed (toggle/slider/segmented/stepper) |
| `onIndexChanged` | int | selection index changed (tabbar/segmented) |
| `onSubmitted` | string | text submitted (search bar) |

Use the most specific name; document any new event in this table via a PR.

### Gesture recognizers (critical for touch)

Set `gestureRecognizers` on the `UiKitView`:

- **Decorative / non-interactive** (container, progress, activity indicator):
  empty set `<Factory<OneSequenceGestureRecognizer>>{}` → forwards touches to
  Flutter.
- **Tap-only** (button, icon button, menu trigger): a `TapGestureRecognizer`
  factory, so the full down→up reaches the native control and the interactive
  glass settles back.
- **Continuous / drag** (slider, switch, segmented, stepper, date/color picker):
  an `EagerGestureRecognizer` factory, so the native control owns all touches.

---

## 4. Availability tiers & the glass recipe

Gate behavior by OS version. Every widget must define all four tiers:

| Tier | Behavior |
| --- | --- |
| **iOS 26+** | Authentic Liquid Glass via `glassEffect` (see recipe). |
| **iOS 16–25** | Standard SwiftUI styling for the control. |
| **iOS 14–15** | System UIKit/SwiftUI control, no glass. |
| **non-iOS** | Flutter Material fallback in the Dart widget (`defaultTargetPlatform != TargetPlatform.iOS`). |

### The glass recipe (iOS 26)

Apply `glassEffect` to **real content**, never to an empty `Color.clear`
(that was the original "flat" bug). Wrap related glass elements in a
`GlassEffectContainer`.

```swift
@available(iOS 26.0, *)
private func resolvedGlass() -> Glass {
  var glass = Glass.regular
  if interactive { glass = glass.interactive() }   // touch reaction
  if let tint { glass = glass.tint(Color(uiColor: tint)) }
  return glass
}

// usage
GlassEffectContainer(spacing: 20) {
  content
    .contentShape(shape)
    .glassEffect(resolvedGlass(), in: shape)
}
```

- `shape` is usually `Capsule()` or `RoundedRectangle(cornerRadius:style:.continuous)`.
- For controls that already have a native glass appearance on iOS 26 (e.g.
  `Toggle`, `Slider`), prefer the system control and only apply `.tint(...)`;
  don't force a manual `glassEffect` where the system already provides one. Use
  judgment and verify on the simulator.

---

## 5. Canonical template (copy this skeleton)

> Reference, not literal final code — adapt per widget. Mirrors
> `GlassButtonView.swift` / `liquid_glass_button.dart`.

### Swift — `ios/Classes/GlassFooView.swift`

```swift
import Flutter
import SwiftUI
import UIKit

final class GlassFooViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger
  init(messenger: FlutterBinaryMessenger) { self.messenger = messenger; super.init() }
  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?)
    -> FlutterPlatformView {
    GlassFooPlatformView(
      frame: frame, viewId: viewId, args: args as? [String: Any] ?? [:], messenger: messenger)
  }
}

final class GlassFooPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let channel: FlutterMethodChannel
  private let model: GlassFooModel
  private var host: UIViewController?

  init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "flutter_native_view/glass_foo/\(viewId)", binaryMessenger: messenger)
    model = GlassFooModel(args: args)
    container.backgroundColor = .clear
    super.init()

    model.onChanged = { [weak channel] value in
      channel?.invokeMethod("onChanged", arguments: value)
    }

    if #available(iOS 16.0, *) {
      let hosting = UIHostingController(rootView: GlassFooRoot(model: model))
      hosting.view.backgroundColor = .clear
      hosting.view.frame = container.bounds
      hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      container.addSubview(hosting.view)
      host = hosting
    }

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize": result(self.intrinsicSize())
      case "updateConfig":
        self.model.apply(args: call.arguments as? [String: Any] ?? [:])
        DispatchQueue.main.async { result(self.intrinsicSize()) }
      case "setValue": /* update model */ result(nil)
      default: result(FlutterMethodNotImplemented)
      }
    }
  }

  private func intrinsicSize() -> [String: Double] {
    guard let view = host?.view else { return ["width": 100, "height": 44] }
    view.setNeedsLayout(); view.layoutIfNeeded()
    let s = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    return ["width": Double(s.width), "height": Double(s.height)]
  }

  func view() -> UIView { container }
}

// Model is plain Combine ObservableObject — NOT @available-gated (works iOS 14+).
final class GlassFooModel: ObservableObject {
  @Published var ...
  var onChanged: ((Any) -> Void)?
  init(args: [String: Any]) { /* parse */ }
  func apply(args: [String: Any]) { /* mutate @Published */ }
}

@available(iOS 16.0, *)
struct GlassFooRoot: View {
  @ObservedObject var model: GlassFooModel
  @Namespace private var namespace
  var body: some View {
    if #available(iOS 26.0, *) { /* glass path */ }
    else { /* standard path */ }
  }
}
```

> **Availability gotcha:** the `*Model` class must NOT carry
> `@available(iOS 16.0, *)` (the platform view constructs it on iOS 14). Only the
> SwiftUI `*Root` view is gated to iOS 16.

### Dart — `lib/src/liquid_glass_foo.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String _kFooViewType = 'flutter_native_view/glass_foo';

class LiquidGlassFoo extends StatefulWidget {
  const LiquidGlassFoo({super.key, /* params */});
  @override
  State<LiquidGlassFoo> createState() => _LiquidGlassFooState();
}

class _LiquidGlassFooState extends State<LiquidGlassFoo> {
  MethodChannel? _channel;
  Size? _size; // only for content-sized widgets

  Map<String, dynamic> _params() => <String, dynamic>{ /* ... */ };

  Future<void> _onCreated(int id) async {
    final channel = MethodChannel('$_kFooViewType/$id');
    channel.setMethodCallHandler((call) async {
      // route events to widget callbacks
      return null;
    });
    _channel = channel;
    // content-sized widgets only:
    // await _applySize(channel.invokeMapMethod<String, dynamic>('getIntrinsicSize'));
  }

  @override
  void didUpdateWidget(covariant LiquidGlassFoo old) {
    super.didUpdateWidget(old);
    // push changes: updateConfig (re-measure) or setValue
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return /* Material fallback */;
    }
    return SizedBox(
      width: /* fixed or _size */,
      height: /* fixed or _size */,
      child: UiKitView(
        viewType: _kFooViewType,
        creationParams: _params(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{ /* per §3 */ },
      ),
    );
  }
}
```

---

## 6. Intrinsic-size handshake (content-sized widgets)

Platform views have no intrinsic size in Flutter, so content-sized widgets
(button, icon button, segmented control, stepper) negotiate it:

1. Dart shows the view in a `SizedBox` of a sensible fallback size.
2. On `onPlatformViewCreated`, Dart calls `getIntrinsicSize`.
3. Native lays out the hosting view and returns
   `systemLayoutSizeFitting(.layoutFittingCompressedSize)`.
4. Dart `setState`s the real size; the `SizedBox` updates.
5. On config change, `updateConfig` returns the new size; re-apply.

Fixed-size widgets (toggle, activity indicator, fixed-height bars) skip this and
use constant dimensions.

---

## 7. Widget catalog (tasks)

Status: ✅ done · ⬜ todo. Complexity: S/M/L. Each row is one agent task unless
noted. **Do not start the modal group (Sheet/Alert/Popover) until the
`LiquidGlassPresenter` task is merged — it is a shared dependency.**

| # | Widget | viewType (`flutter_native_view/…`) | Cx | Sizing | Gestures | Status |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Button | `glass_button` | M | intrinsic | tap | ✅ |
| 2 | Switch/Toggle | `glass_toggle` | S | fixed | eager | ✅ |
| 3 | IconButton | `glass_icon_button` | S | intrinsic | tap | ✅ |
| 4 | Container | `glass_container` | S | parent | none | ✅ |
| 5 | Slider | `glass_slider` | M | parent-w/fixed-h | eager | ✅ |
| 6 | SegmentedControl | `glass_segmented` | M | intrinsic | eager | ✅ |
| 7 | Stepper | `glass_stepper` | M | intrinsic | tap | ✅ |
| 8 | SearchBar | `glass_search_bar` | M | parent-w/fixed-h | eager | ✅ |
| 9 | TabBar | `glass_tab_bar` | L | fixed-h | eager | ✅ |
| 10 | NavigationBar | `glass_navigation_bar` | M | fixed-h | tap | ✅ |
| 11 | Toolbar | `glass_toolbar` | M | fixed-h | tap | ✅ |
| 12 | Menu | `glass_menu` | M | intrinsic | tap | ✅ |
| 13 | DatePicker | `glass_date_picker` | M | intrinsic | eager | ✅ |
| 14 | ColorPicker | `glass_color_picker` | M | intrinsic | tap | ✅ |
| 15 | ActivityIndicator | `glass_activity_indicator` | S | fixed | none | ✅ |
| 16 | ProgressView | `glass_progress` | S | parent-w/fixed-h | none | ✅ |
| 17 | ButtonGroup | `glass_button_group` | M | intrinsic | tap | ✅ |
| 0a | **Presenter (shared)** | n/a (modal host) | L | n/a | n/a | ✅ |
| 18 | Sheet | via presenter | M | n/a | n/a | ✅ |
| 19 | Alert | via presenter | M | n/a | n/a | ✅ |
| 20 | Popover | via presenter | M | n/a | n/a | ✅ |

### Per-widget specs

Only the non-trivial details are listed; everything else follows §5.

**3 · IconButton** — `LiquidGlassButton.icon`-style or `LiquidGlassIconButton`.
- Dart: `{ NativeIcon icon, VoidCallback? onPressed, double size, double iconSize, Color? tint, double? borderRadius, bool interactive }`.
- Icon: support SF Symbol by name (`sfSymbol: String`) rendered via `Image(systemName:)`; optionally a Flutter `IconData`/asset rasterized to PNG bytes passed as `iconPng` (advanced — can be a follow-up). Start with SF Symbol only.
- params: `{ sfSymbol, size, iconSize, tint, cornerRadius, interactive }`.
- Native: SwiftUI `Button { Image(systemName:).font(.system(size: iconSize)) }` + glass; circle shape when no radius.
- Fallback: `IconButton.filled`.

**4 · Container** — decorative glass panel. `LiquidGlassContainer({ Widget? child, GlassStyle... })`.
- It is a glass *surface*; Flutter content is stacked on top in Dart (Stack: UiKitView fill + child). The native side renders only the glass shape.
- params: `{ tint, cornerRadius }`. Native: `Color.clear`-free — fill a shape and apply glass: `RoundedRectangle(...).glassEffect(...)` content. Gestures: empty (decorative).
- Sizing: fills parent (`Positioned.fill` under the child).
- Fallback: `DecoratedBox` with translucent tint + border.

**5 · Slider** — `LiquidGlassSlider({ double value, ValueChanged<double> onChanged, double min, double max, Color? tint })`.
- params: `{ value, min, max, tint }`. Events: `onChanged(double)`. Methods: `setValue(double)`.
- Native: SwiftUI `Slider(value:in:)`; `.tint(tint)`. Sizing: parent width, fixed height ~32.
- Fallback: Material `Slider`.

**6 · SegmentedControl** — `LiquidGlassSegmentedControl({ List<String> segments, int selectedIndex, ValueChanged<int> onChanged, Color? tint })`.
- params: `{ segments: [String], selectedIndex, tint }`. Event: `onIndexChanged(int)`. Method: `updateConfig`.
- Native: SwiftUI `Picker(...).pickerStyle(.segmented)` or a custom glass segmented row on iOS 26; tint selection.
- Sizing: intrinsic. Fallback: Material `SegmentedButton`.

**7 · Stepper** — `LiquidGlassStepper({ int value, ValueChanged<int> onChanged, int step, int? min, int? max })`.
- params: `{ value, step, min, max }`. Event: `onChanged(int)`. Method: `setValue(int)`.
- Native: SwiftUI `Stepper`. Sizing: intrinsic. Fallback: two `IconButton`s + label.

**8 · SearchBar** — `LiquidGlassSearchBar({ String text, ValueChanged<String> onChanged, ValueChanged<String>? onSubmitted, String? placeholder })`.
- params: `{ text, placeholder }`. Events: `onChanged(String)`, `onSubmitted(String)`. Method: `setText(String)`.
- Native: SwiftUI `TextField` styled with glass capsule + magnifying glass SF Symbol. Sizing: parent width, fixed height.
- Fallback: Material `TextField` with search decoration.
- ⚠ Keyboard: native text input inside a platform view works, but verify focus & keyboard on the simulator.

**9 · TabBar** — `LiquidGlassTabBar({ List<TabItem> items, int currentIndex, ValueChanged<int> onTap })`.
- `TabItem { String label, String sfSymbol }`. params: `{ items: [{label, sfSymbol}], currentIndex }`. Event: `onIndexChanged(int)`.
- Native: a horizontal glass bar of buttons (use `GlassEffectContainer` so items share one glass surface). Fixed height ~56–64.
- Fallback: Material `NavigationBar`.

**10 · NavigationBar** — top bar: `LiquidGlassNavigationBar({ String? title, List<BarAction> leading, trailing })`.
- `BarAction { String sfSymbol, VoidCallback onPressed }` keyed by id. Event: `onAction(String id)`.
- Native: glass bar with title + action buttons. Fixed height. Fallback: `AppBar`.

**11 · Toolbar** — bottom action bar of icon buttons. Similar to NavigationBar; `onAction(String id)`. Fallback: `BottomAppBar`.

**12 · Menu** — `LiquidGlassMenu({ Widget/label trigger, List<MenuItem> items, ValueChanged<String> onSelected })`.
- `MenuItem { String id, String title, String? sfSymbol }`. Event: `onSelected(String id)`.
- Native: SwiftUI `Menu { ForEach … Button } label: { glass trigger }`. Sizing: intrinsic (trigger). Fallback: `PopupMenuButton`.

**13 · DatePicker** — `LiquidGlassDatePicker({ DateTime value, ValueChanged<DateTime> onChanged, DateTime? min, max, mode })`.
- Pass dates as epoch millis. Event: `onChanged(int millis)`. Method: `setValue(int)`.
- Native: SwiftUI `DatePicker`. Sizing: intrinsic. Fallback: `showDatePicker` trigger button.

**14 · ColorPicker** — `LiquidGlassColorPicker({ Color value, ValueChanged<Color> onChanged })`.
- params: `{ color: argb }`. Event: `onChanged(int argb)`. Native: SwiftUI `ColorPicker` (iOS 14+). Sizing: intrinsic. Fallback: a button opening a Flutter color dialog.

**15 · ActivityIndicator** — `LiquidGlassActivityIndicator({ double size, Color? tint })`. Decorative, no events. Native: `ProgressView().progressViewStyle(.circular)`. Fixed size. Fallback: `CircularProgressIndicator`.

**16 · ProgressView** — `LiquidGlassProgressView({ double value, Color? tint })` (0..1). Method: `setValue(double)`. Native: linear `ProgressView(value:)`. Parent width, fixed height. Fallback: `LinearProgressIndicator`.

**17 · ButtonGroup** — a row/segment of glass buttons sharing one `GlassEffectContainer` (glass elements merge). `LiquidGlassButtonGroup({ List<GroupButton> buttons })` where each has label/sfSymbol/onPressed (keyed). Event: `onPressed(String id)`. Intrinsic size. Fallback: `Row` of `LiquidGlassButton`.

**0a · Presenter (shared, do first of the modal group)** —
- A single `LiquidGlassPresenter` registered once in the plugin, owning a
  `FlutterMethodChannel` `flutter_native_view/presenter`.
- Dart side: a `LiquidGlassPresenter` service with `presentSheet/Alert/Popover`
  methods returning a result future; native presents a SwiftUI modal hosted in a
  `UIHostingController` over `registrar.viewController`.
- This unlocks Sheet/Alert/Popover. Specify the channel method names and payload
  in this doc as part of the task, then 18–20 build on it.

**18 · Sheet / 19 · Alert / 20 · Popover** — thin Dart APIs over the presenter.
Define `LiquidGlassSheet.show(context, …)` etc. Glass styling comes from the
native presentation (iOS 26 sheets adopt glass). Fallbacks: `showModalBottomSheet`,
`showDialog`, a Flutter popover/menu.

---

## 8. Parallelization & coordination

### Independent by design
Each widget task touches only:
- `lib/src/liquid_glass_<name>.dart` (new)
- `ios/Classes/Glass<Name>View.swift` (new)
- one line in `lib/liquid_glass_native.dart` (export)
- one factory + one `registrar.register(...)` in `FlutterNativeViewPlugin.swift`
- one demo entry in the example (see below)
- one row in `README.md` table + flip its status in §7

### Shared-file conflict rules
- **`FlutterNativeViewPlugin.swift`**: keep registrations sorted alphabetically
  by viewType. Each agent inserts its `let fooFactory = …` and
  `registrar.register(fooFactory, withId: …)` in sorted position. Conflicts are
  trivial 1-line merges; rebase before pushing.
- **`lib/liquid_glass_native.dart`**: exports sorted alphabetically; same rule.
- **Example app**: do **not** all edit `example/lib/main.dart`. Instead each
  widget gets its own demo file `example/lib/demos/<name>_demo.dart` exposing a
  `Widget build()` and a title; a single `gallery.dart` lists them. The gallery
  list is the only shared example file — sorted, 1-line insert per widget.
- **This doc (`§7` table)**: flip your status to ✅ in your PR.

### Recommended workflow per agent
1. Branch/worktree per widget: `git worktree add ../glass-<name>`.
2. Implement Dart + Swift from §5, wire channel per §3, tiers per §4.
3. `flutter analyze` (lib + example) clean; add a fallback widget test; run
   `flutter test`.
4. Build the example for the iOS simulator to compile Swift:
   `cd example && flutter build ios --simulator --debug`.
5. Add the demo file + gallery entry + README row; flip §7 status.
6. Open a PR; rebase onto main before merge to resolve the sorted shared lines.

### Suggested batching (to minimize churn)
- **Wave 1 (simple, no deps):** IconButton, Container, ActivityIndicator,
  ProgressView, Slider, Stepper.
- **Wave 2 (medium):** SegmentedControl, SearchBar, Menu, DatePicker,
  ColorPicker, ButtonGroup.
- **Wave 3 (bars):** TabBar, NavigationBar, Toolbar.
- **Wave 4 (modals):** Presenter first, then Sheet, Alert, Popover.

---

## 9. Definition of Done (every task)

- [ ] Dart widget + Swift view implemented per §5, original code only.
- [ ] All four availability tiers handled; no crash on any platform.
- [ ] Channel protocol matches §3 (events + methods named per table).
- [ ] `flutter analyze` clean for `lib`, `test`, and `example/lib`.
- [ ] A fallback widget test added under `test/`; `flutter test` passes.
- [ ] `cd example && flutter build ios --simulator --debug` succeeds.
- [ ] Demo file + gallery entry added; widget visible in the example.
- [ ] README widget table row added; §7 status flipped to ✅.
- [ ] Manually verified on an **iOS 26 simulator** (glass renders, interaction
      works) — note the result in the PR.

---

## 10. Testing notes

- **Host tests** run on a non-iOS target, so they exercise the **Material
  fallback** path only. Material widgets (`Switch`, `Slider`, …) need a
  `Material`/`Scaffold` ancestor — wrap them in tests.
- **Native glass** can only be verified on an **iOS 26 simulator** (older sims
  show the standard tier). Always screenshot and confirm before marking done.
- Keep `GlassColor.swift` the single source of ARGB decoding; do not duplicate.

---

## 11. Reference implementations

Study these before starting — they are the source of truth for the pattern:

- `lib/src/liquid_glass_button.dart` + `ios/Classes/GlassButtonView.swift`
  (intrinsic-size handshake, tap gesture, updateConfig).
- `lib/src/liquid_glass_switch.dart` + `ios/Classes/GlassToggleView.swift`
  (fixed size, eager gesture, setValue, value event).
- `ios/Classes/FlutterNativeViewPlugin.swift` (factory registration).
- `ios/Classes/GlassColor.swift` (ARGB decode).
