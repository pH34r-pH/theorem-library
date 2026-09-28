# Theorem Library

Theorem Library contains **machine-checkable mathematical results extracted from an empirical research program** so the formal claims can be inspected independently of the surrounding experiments.

The current public core focuses on vector normalization and hyperspherical geometry: what normalization preserves and removes, the exact structure of its derivative, and which local conclusions survive composition with surrounding computation.

## Start here

- [Getting started](Getting-Started.md)
- [Theorem map](Theorem-Map.md)
- [Formalization scope](Formalization-Scope.md)
- [Architecture and namespaces](Architecture-and-Namespaces.md)
- [Verification](Verification.md)
- [Research relationship](Research-Relationship.md)
- [Contributing proofs](Contributing-Proofs.md)
- [Publication and provenance](Publication-and-Provenance.md)

## The governing boundary

A successful Lean build establishes that the encoded theorem follows from its encoded assumptions in the pinned formal environment.

It does **not** establish that a particular trained model satisfies those assumptions, that the theorem explains an observed result, or that the empirical interpretation is novel.

Those links are argued separately in Research Notes and the research program.

Stable `LIB-*` / `FRM-*` identifiers make theorem references durable even when source modules are reorganized.
