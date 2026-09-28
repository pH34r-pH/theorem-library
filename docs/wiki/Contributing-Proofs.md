# Contributing proofs

A useful contribution strengthens the reusable formal core without blurring the scientific boundary.

## Before proposing a theorem

1. Check [INDEX.md](https://github.com/pH34r-pH/theorem-library/blob/main/INDEX.md) for an existing result or identifier.
2. Check [PUBLIC_CORE.md](https://github.com/pH34r-pH/theorem-library/blob/main/PUBLIC_CORE.md) for the intended exported surface.
3. Follow [NAMESPACE.md](https://github.com/pH34r-pH/theorem-library/blob/main/NAMESPACE.md).
4. State assumptions narrowly enough that the theorem says exactly what it proves.

## Proof style

Prefer reusable lemmas and existing Mathlib abstractions over bespoke definitions. Keep imports narrow enough to make dependencies intelligible. Avoid encoding an empirical interpretation into a theorem name when the formal statement is more general.

## Validation

Run the pinned bootstrap/build/check sequence before submitting a pull request. A new exported theorem should be indexed in human-readable form and, where it is intended as a research checkpoint, receive or reuse a stable identifier.

## Claim discipline

Do not describe “Lean accepts this theorem” as evidence that an empirical model satisfies its assumptions. If a PR changes the research interpretation, that belongs in the corresponding research documentation too.
