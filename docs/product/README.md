# Product Docs

This directory contains focused consumer-product behavior derived from accepted
intent. Harness deliberately ships no fake product domains.

The current Liquid Glass contract is primarily documented in the root
`README.md`, `docs/ARCHITECTURE.md`, source code, tests, and design documents.
Add a focused document here only when a behavior needs a durable product-level
explanation.

## Update Rule

When behavior changes:

1. Update the affected product document when expected behavior changes.
2. Update the relevant code and executable proof.
3. Use one active execution plan only when the work spans sessions, coordinates
   contributors, has meaningful dependencies, or needs recovery.
4. Add a lasting decision only when future work must inherit a consequential
   product, architecture, compatibility, security, data, or validation choice.

Bounded changes do not require a parallel lifecycle record.
