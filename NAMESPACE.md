# Namespace convention

Reusable mathematics in this repository lives under `TheoremLibrary.*`.

The namespace is intended for results that can stand independently of a particular experiment: their statements should be mathematical, their assumptions explicit, and their usefulness broader than one run or dataset. Research-specific formalizations can import this package without moving experiment names, empirical assumptions, or research-state machinery into the reusable library.

```text
Mathlib
  ↓
TheoremLibrary.*   reusable public mathematics
  ↓
research-specific formalization and applications
```

Stable `FRM-*` and `LIB-*` identifiers may be attached to public results when the same mathematical object is referenced elsewhere in the research. The identifier provides continuity across module or declaration refactors; the Lean declaration remains the machine-checkable statement.
