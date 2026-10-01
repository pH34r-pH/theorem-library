# `Geometry/Sphere/` map

These modules form the current public mathematical thread. Read the repository [`../../../AGENTS.md`](../../../AGENTS.md) and [`../../../INDEX.md`](../../../INDEX.md) before editing.

## Module relationships

| Module | Role | Depends on |
| --- | --- | --- |
| `Projection.lean` | Finite-dimensional tangent projection identities. | Mathlib finite sums/real basics. |
| `NormDerivative.lean` | Fréchet derivative of the norm away from zero. | Mathlib inner-product calculus and square roots. |
| `Normalization.lean` | Derivative of `x ↦ x / ‖x‖`, including radial/tangent action. | `NormDerivative.lean`, calculus of inverse/product. |
| `Anisotropy.lean` | Exact radial annihilation and tangent gain separation. | `Normalization.lean`. |
| `ScaleInvariantLoss.lean` | First-order loss/gradient and explicit normalized-step identities. | `Anisotropy.lean`, calculus. |
| `RadialMemory.lean` | Positive-scale quotient and downstream information boundary. | `Anisotropy.lean`, function iteration. |
| `NormalizationSpectrum.lean` | Kernel, range, rank, and singular values. | `Anisotropy.lean`, finite-dimensional singular values. |
| `NormalizationComposition.lean` | Conditions and counterexample for pre/post normalization composition. | `NormalizationSpectrum.lean`. |
| `NormalizationGradient.lean` | Gradients of losses composed with normalization. | `NormalizationSpectrum.lean`, `ScaleInvariantLoss.lean`. |

`TheoremLibrary.lean` imports these modules in public order. The `INDEX.md` stable identifiers and each module's docstring are the claim map; do not infer a stronger system or empirical statement from a local theorem.

## Change routing and validation

- Change projection or norm calculus in the foundational module and validate downstream imports.
- Change the derivative or radial/tangent theorem in `Normalization.lean`/`Anisotropy.lean` only with corresponding updates to dependent theorem proofs and the human-readable index.
- Change spectral, composition, gradient, or radial-memory consequences in their own module; preserve the explicit assumptions and boundary caveats.

Focused commands:

```sh
lake env lean TheoremLibrary/Geometry/Sphere/Normalization.lean
lake build TheoremLibrary
```

Run `bash scripts/validate_formal.sh` for the full placeholder and axiom audit. A successful Lean check is formal evidence only; empirical correspondence remains in the Research Notes repository.
