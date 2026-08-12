# Project Rules

<!-- HARNESS:BEGIN -->
## Harness

Claude Code loads this file into every session, but it does not auto-load
`AGENTS.md`. Import that single canonical project instruction source. Keep this
bare `@` line outside backticks so the import remains active.

@AGENTS.md
<!-- HARNESS:END -->

## Project Notes

- **Harness core is installed locally.** Use `scripts/bin/harness status` and
  `scripts/bin/harness doctor` for Harness maintenance. Product validation is
  still owned by Flutter commands in `README.md`.
- **Name mismatch is intentional — do not "fix" it.** The Dart package is
  `liquid_glass_native`, but the iOS plugin class is `FlutterNativeViewPlugin`
  and every platform-view type / method-channel ID uses the `flutter_native_view/`
  prefix (e.g. `flutter_native_view/glass_button`). Dart and Swift sides must
  agree on these strings, so renaming one side breaks the channel wiring.
