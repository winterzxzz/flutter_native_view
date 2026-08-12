# Decisions

Decision records preserve lasting product, architecture, compatibility,
security, data-ownership, and validation choices.

Use `docs/templates/decision.md` for a new record. Task-local choices stay in
the active execution plan.

## Consumer Decisions

Add a decision when:

- a lasting product or architecture choice changes;
- public compatibility or data ownership changes;
- security or recovery policy changes;
- validation is materially added, removed, or weakened; or
- the source-of-truth hierarchy changes.

The upstream Harness decisions remain in the `repository-harness` source
repository. They are represented here only by the installed core behavior and
are not copied into this consumer repository as product history.

## Historical Harness Records

The former Harness v0 decisions are preserved in Git history. They are not
current authority after the migration to the repository-centered core.
