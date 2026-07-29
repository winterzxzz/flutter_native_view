# Liquid Glass Native v1 Product Contract

Date: 2026-07-30

## Product Definition

`liquid_glass_native` is a Flutter plugin that embeds native SwiftUI controls
whose visible content and Liquid Glass treatment are rendered by Apple APIs.
It is a control library, not a generic Flutter blur or arbitrary-content
compositor.

## Platform Promise

- iOS 26 and newer use system Liquid Glass APIs. Buttons use SwiftUI glass
  button styles; custom control backgrounds use `glassEffect` after layout and
  appearance modifiers; grouped buttons share one `GlassEffectContainer`.
- iOS 15 through 25 render custom surfaces with SwiftUI `ultraThinMaterial`
  and standard controls with their native system styles. They never render an
  empty platform view or substitute a plain translucent color for material.
- Non-iOS platforms render stable Material fallbacks with matching controlled
  values and callbacks.
- Accessibility is not optional. Reduce Transparency forces a fully opaque
  custom surface even when the configured tint contains transparency. Reduce
  Motion suppresses explicitly interactive custom glass. Native system
  controls retain the operating system's accessibility behavior.

## Public Styling Contract

The package exports one composable vocabulary:

- `LiquidGlassVariant`: `regular` or `clear`.
- `LiquidGlassShape`: capsule, circle, or a continuous rounded rectangle with a
  validated corner radius.
- `LiquidGlassStyle`: glass variant, optional tint, shape, and interactivity
  for controls that own a custom glass surface.
- `LiquidGlassControlSize`: compact, regular, or large.
- `LiquidGlassControlStyle`: system tint, foreground color, brightness,
  semantic control size, and disabled opacity.
- `LiquidGlassThemeData`: the subtree defaults for `style` and `controlStyle`.
- `LiquidGlassTheme`: an `InheritedTheme`; every mounted native view receives
  live theme changes through the synchronized bridge.
- `LiquidGlassSymbol`: an SF Symbol name paired with an optional Material icon
  for non-iOS fallback rendering.

An explicit widget style replaces that widget's themed style. `copyWith` on the
immutable style objects is the supported way to derive a local variation from
the current theme; `clearTintColor`, `clearForegroundColor`, and
`clearBrightness` explicitly remove nullable control-style values.

Customization is capability-based rather than pretending every property maps
to every Apple control:

| Control category | Public customization |
| --- | --- |
| Custom glass surface: button, button group, checkbox, menu trigger, text/search field | `LiquidGlassStyle` plus `LiquidGlassControlStyle` |
| Standard system control: switch, slider, stepper, segmented control, date picker, color picker | `LiquidGlassControlStyle` only; `tintColor` is the native/Material accent |

Standard controls intentionally do not accept `LiquidGlassStyle`: Apple owns
their system appearance, and applying arbitrary custom glass around them would
over-decorate rather than authentically adapt the control. On Material,
`LiquidGlassStyle.variant` and interactive optical behavior have no native
equivalent; fallbacks preserve shape/tint where the control owns a surface.

## Retained v1 Controls

| Interface | Contract |
| --- | --- |
| `LiquidGlassButton` | Native label/symbol button with standard, prominent, and icon constructors |
| `LiquidGlassButtonGroup` | Multiple native buttons inside one platform view and one `GlassEffectContainer` |
| `LiquidGlassSwitch` | Controlled native toggle; nullable callback disables it |
| `LiquidGlassCheckbox` | Controlled custom native checkbox |
| `LiquidGlassSlider` | Finite, validated range and controlled value |
| `LiquidGlassStepper` | Positive step and validated optional integer bounds |
| `LiquidGlassSegmentedControl<T>` | Typed values mapped to native indices; selection always belongs to the segment list |
| `LiquidGlassTextField` / `.search` | Stable controller-backed input with typed keyboard, capitalization, submit, and one honest autocorrection/suggestion capability |
| `LiquidGlassMenu<T>` | Typed item values mapped from native selection indices |
| `LiquidGlassDatePicker` | Typed displayed-components enum and validated year-1-through-9999 date range |
| `LiquidGlassColorPicker` | Controlled ARGB color value; opacity capability is honored by native and Material pickers |

Public constructors assert programmer invariants early: non-empty item sets,
unique button identifiers, selected values present in their collection, finite
numeric values, ordered bounds, and positive steps.

## Retired Pre-v1 Interfaces

The following interfaces are intentionally not part of v1:

- `LiquidGlassContainer` and `LiquidGlassCard`: a native empty surface behind a
  Flutter child cannot guarantee that SwiftUI Liquid Glass samples or wraps the
  Flutter render tree authentically.
- `LiquidGlassActivityIndicator` and `LiquidGlassProgressView`: these were
  platform-view wrappers around standard progress controls, not glass modules.
- `LiquidGlassNavigationBar`, `LiquidGlassTabBar`, and `LiquidGlassToolbar`:
  their previous shells either multiplied platform views or embedded native
  controller chrome without native content ownership.
- `LiquidGlassSheet`, `LiquidGlassAlert`, `LiquidGlassPopover`, and
  `LiquidGlassPresenter`: they presented fixed native placeholder content and
  could not compose caller-provided Flutter content.
- `LiquidGlassLabeledSwitch`: it was a shallow row convenience.
- `LiquidGlassIconButton` and `LiquidGlassSearchBar`: replaced by
  `LiquidGlassButton.icon` and `LiquidGlassTextField.search`.

Migration examples live in `README.md` and `CHANGELOG.md`.

## State And Lifecycle Contract

- Creation parameters contain one complete, validated snapshot.
- Rebuilds perform deep structural comparison; equal maps and lists do not
  generate method-channel traffic.
- Theme and widget changes in one frame coalesce into at most one
  `updateConfig` call per native view.
- Native value events optimistically patch the last-sent snapshot before
  invoking Dart callbacks and schedule a post-frame reconciliation. An
  accepted parent rebuild matches native and produces no echo; a rejected
  callback or missing rebuild sends the authoritative Dart value back.
- Text controllers remain stable and preserve full fallback editing state.
  SwiftUI 15 does not expose authoritative selection/marked-text ranges, so
  native text edits map the existing selection and composing ranges through
  the text delta rather than collapsing them. Dart-originated controller
  selection/composing changes are not pushed to the native field.
- Intrinsic-size responses are revision guarded and only rebuild Flutter when
  the reported size changes.
- Channel handlers are cleared on disposal; native hosting controllers detach
  their views and handlers during deinitialization.

## Performance Contract

Every standalone native control costs one `UiKitView`, one hosting controller,
and one per-view method channel. `LiquidGlassButtonGroup` amortizes that cost
for related actions and is the preferred grouped-action interface. Consumers
should not place many platform views in recycling or rapidly scrolling lists.

`LiquidGlassDiagnostics` counts created views, outbound config updates, native
events, and intrinsic measurements without recording labels, text, colors, or
other payload data. The counts are deterministic instrumentation, not a claim
about frame time, GPU time, memory, or on-device energy. Those require an iOS
26 device or simulator plus Instruments.
