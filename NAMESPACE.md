# Namespace boundary

Reusable public formal mathematics is defined under `TheoremLibrary.*`.

The private research program may import this package from `domain-scaling-lab`, but research-specific formalization remains under `DomainScaling.*`. Stable `FRM-*` and `LIB-*` identifiers preserve theorem identity across module/declaration refactors.

This distinction is intentional:

```text
Mathlib
  ↓
TheoremLibrary.*   public reusable mathematics
  ↓
DomainScaling.*    private research-specific formalization
  ↓
private theorem ledger / ontology / empirical program
```

A successful public proof build establishes only the encoded mathematical statement. Scientific correspondence, empirical assumptions, and research-program promotion remain outside this repository.
