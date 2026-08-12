# Scripts

The repository-local Harness maintenance binary is installed at
`scripts/bin/harness` and owns core installation, provenance, safe updates,
status, diagnostics, conflict continuation, and recovery.

## Harness Commands

```bash
scripts/bin/harness status --json
scripts/bin/harness doctor --json
scripts/bin/harness update --dry-run --json
scripts/bin/harness update
scripts/bin/harness update --continue
scripts/bin/harness update --abort
```

`harness update` preserves local edits through a three-way merge. If managed
files overlap with upstream changes, it stages BASE, LOCAL, UPSTREAM, and
RESOLVED copies under `.harness-core/update/` and waits for human direction.

## Consumer Validation

Product validation remains Flutter-owned. Use the commands in the root
`README.md` for dependency installation, analysis, widget tests, and iOS runtime
proof.

The former SQLite `harness-cli` protocol and its schemas are end-of-life and no
longer part of the active scripts surface. Their history remains available in
Git for repositories that explicitly need to recover old data.
