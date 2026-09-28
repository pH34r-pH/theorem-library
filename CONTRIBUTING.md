# Contributing to Theorem Library

Contributions should strengthen the reusable formal core while preserving the boundary between formal mathematics and empirical interpretation.

## Before submitting

- Read `INDEX.md`, `PUBLIC_CORE.md`, and `NAMESPACE.md`.
- Use existing Mathlib concepts where they fit instead of creating parallel definitions.
- Keep assumptions explicit and statements no stronger than needed.
- Add/update the human-readable theorem index for exported results.
- Run the pinned bootstrap, build, development check, and formal validation scripts.

A theorem accepted by Lean establishes the encoded statement under encoded assumptions. Do not describe that as empirical validation without a separate argument.
