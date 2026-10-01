# `TheoremLibrary/` map

This is the reusable formal core. Read the repository [`AGENTS.md`](../AGENTS.md), [`INDEX.md`](../INDEX.md), [`PUBLIC_CORE.md`](../PUBLIC_CORE.md), and [`NAMESPACE.md`](../NAMESPACE.md) before editing declarations.

## Import surface and data flow

[`TheoremLibrary.lean`](../TheoremLibrary.lean) imports the public module chain. All declarations live under `TheoremLibrary.Geometry.Sphere`; Mathlib supplies the underlying analysis, inner-product, linear-algebra, and calculus structures. Lean elaborates the source against the pinned environment, then `lake build`, `leanchecker`, and `axiom-audit` provide the repository verification layers.

The source dependency shape is:

```text
Projection + NormDerivative
        -> Normalization
        -> Anisotropy
        -> ScaleInvariantLoss / RadialMemory / NormalizationSpectrum
        -> NormalizationComposition / NormalizationGradient
```

The exact import surface is authoritative in [`../TheoremLibrary.lean`](../TheoremLibrary.lean) and each module header/import list.

## Invariants and change routing

- Keep statements mathematical and assumptions explicit; do not encode empirical interpretation into theorem names or hypotheses without a formal reason.
- Preserve the local/global boundary: a theorem about one normalization derivative does not automatically describe a recurrent product or trained model.
- For a new foundational identity, route to the narrowest module; for a derived public result, route to the downstream module and update [`../INDEX.md`](../INDEX.md) and [`../PUBLIC_CORE.md`](../PUBLIC_CORE.md) as needed.
- For a cross-repository explanation, update the Research Notes formal checkpoint link rather than copying proof source.
- Never use `sorry` or `admit` to close a proof.

Focused validation:

```sh
lake build TheoremLibrary
lake env lean TheoremLibrary.lean
```

Run [`../scripts/dev_check.sh`](../scripts/dev_check.sh) and [`../scripts/validate_formal.sh`](../scripts/validate_formal.sh) before merge.
