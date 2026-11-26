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

The applicability records linked from [the index](INDEX.md) own the mapping
from stable identifiers and aliases to public Lean declarations.
`LIB-SPH-001/005` is a combined heading for two existing identifiers.
`LIB-SPH-001` covers the positive-scale quotient, and `LIB-SPH-005` covers
the downstream radial-memory boundary. Each retains its own declaration binding.

A module move updates the recorded path, index links, and public import
inventory while preserving the qualified declarations. A declaration rename
retains the old public name as a Lean alias and records the replacement and
provenance. A materially different proposition needs a new identifier.
The pinned proof job checks the qualified names through the public import and
compares existing bindings against the reviewed base.
