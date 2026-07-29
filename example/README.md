# liquid_glass_native example

The example contains:

- a v1 control gallery with typed styles and selections;
- live theme synchronization;
- payload-free bridge diagnostics;
- the preserved weather sample migrated to v1 controls.

Run:

```sh
flutter run
```

Build the real Swift bridge for the iOS simulator:

```sh
flutter build ios --simulator --debug
```

An iOS 26 runtime is required to inspect the actual Liquid Glass material.
iOS 15–25 display native SwiftUI controls and `ultraThinMaterial` custom
surfaces; other platforms display Material fallbacks.
