# Project Rules

<!-- HARNESS:BEGIN -->
## Harness

Claude Code loads this file into every session, but it does not auto-load
`AGENTS.md`. The bare `@` lines below import the always-required harness
context (the "Must in all lanes" set from `docs/CONTEXT_RULES.md`) at
context-load time. Never wrap them in backticks; that disables the import.

@AGENTS.md

@docs/FEATURE_INTAKE.md

Also run `scripts/bin/harness-cli query matrix` before starting work.

Lane-dependent context (`README.md`, `docs/HARNESS.md`, `docs/ARCHITECTURE.md`,
`docs/CONTEXT_RULES.md`, product docs, stories, decisions) is intentionally not
imported — read it per lane, as `docs/CONTEXT_RULES.md` prescribes.
<!-- HARNESS:END -->

## Project Notes

- **Harness CLI is not checked in.** `scripts/bin/harness-cli` does not exist in
  this repo, so the "run harness-cli ..." steps above and in `AGENTS.md` cannot
  execute. Treat Harness as docs-only unless the binary is installed; don't burn
  a turn invoking it.
- **Name mismatch is intentional — do not "fix" it.** The Dart package is
  `liquid_glass_native`, but the iOS plugin class is `FlutterNativeViewPlugin`
  and every platform-view type / method-channel ID uses the `flutter_native_view/`
  prefix (e.g. `flutter_native_view/glass_button`). Dart and Swift sides must
  agree on these strings, so renaming one side breaks the channel wiring.
