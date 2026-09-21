# Theorem index

This index is the human-readable entry point to the public Lean library. It describes what each stable result says and links to the source that proves it. Research-specific interpretation lives in the [Research Notes](https://github.com/pH34r-pH/research-notes).

## Hypersphere normalization

### LIB-SPH-002 / FRM-000020 — normalization derivative anisotropy

For a nonzero vector, normalization removes infinitesimal motion in the radial direction and scales tangent motion by inverse radius. At unit radius, tangent motion is preserved to first order.

**Source:** [Anisotropy.lean](TheoremLibrary/Geometry/Sphere/Anisotropy.lean) · [Normalization.lean](TheoremLibrary/Geometry/Sphere/Normalization.lean)

**Research explanation:** [Formal checkpoint](https://github.com/pH34r-pH/research-notes/blob/main/reference/formal-methods/checkpoints.md#lib-sph-002--frm-000020--normalization-derivative-anisotropy)

### LIB-SPH-003 / FRM-000021 — scale-invariant loss geometry

For differentiable losses composed through normalization, first-order radial sensitivity vanishes. Related results characterize normalized tangent updates and their angular scaling.

**Source:** [ScaleInvariantLoss.lean](TheoremLibrary/Geometry/Sphere/ScaleInvariantLoss.lean) · [NormalizationGradient.lean](TheoremLibrary/Geometry/Sphere/NormalizationGradient.lean)

**Research explanation:** [Formal checkpoint](https://github.com/pH34r-pH/research-notes/blob/main/reference/formal-methods/checkpoints.md#lib-sph-003--frm-000021--scale-invariant-loss-geometry)

### LIB-SPH-001/005 / FRM-000023 — positive-scale quotient and radial-memory boundary

Positive rescalings of the same nonzero proposal normalize to the same state. Once that radius has been erased, deterministic downstream computation that receives only the normalized state cannot determine which positive rescaling produced it.

This result is deliberately narrower than saying that a recurrent model cannot preserve information previously associated with radius; upstream computation may move such information into direction before normalization.

**Source:** [RadialMemory.lean](TheoremLibrary/Geometry/Sphere/RadialMemory.lean)

**Research explanation:** [Formal checkpoint](https://github.com/pH34r-pH/research-notes/blob/main/reference/formal-methods/checkpoints.md#lib-sph-001005--frm-000023--positive-scale-quotient-and-radial-memory-boundary)

### FRM-000133 — normalization spectrum

In finite-dimensional real inner-product spaces, the derivative of normalization has one radial zero mode and equal inverse-radius gain on tangent modes. The library characterizes its kernel, range, rank, and singular values exactly.

**Source:** [NormalizationSpectrum.lean](TheoremLibrary/Geometry/Sphere/NormalizationSpectrum.lean)

**Research explanation:** [Formal checkpoint](https://github.com/pH34r-pH/research-notes/blob/main/reference/formal-methods/checkpoints.md#frm-000133--normalization-spectrum)

### FRM-000149 — composition and gradient boundaries

These results describe where the radial/tangent properties of normalization survive composition with surrounding maps and give exact gradient identities for differentiable normalized losses.

Their main purpose is to stop a local theorem about normalization from being applied automatically to an entire learned recurrence.

**Source:** [NormalizationComposition.lean](TheoremLibrary/Geometry/Sphere/NormalizationComposition.lean) · [NormalizationGradient.lean](TheoremLibrary/Geometry/Sphere/NormalizationGradient.lean)

**Research explanation:** [Formal checkpoint](https://github.com/pH34r-pH/research-notes/blob/main/reference/formal-methods/checkpoints.md#frm-000149--composition-and-gradient-boundaries)

## Supporting modules

[Projection.lean](TheoremLibrary/Geometry/Sphere/Projection.lean) and [NormDerivative.lean](TheoremLibrary/Geometry/Sphere/NormDerivative.lean) provide supporting identities used by the normalization results.

The exact dependency and import surface is available from [TheoremLibrary.lean](TheoremLibrary.lean) and the individual module imports. [PUBLIC_CORE.md](PUBLIC_CORE.md) lists the modules currently included in the public library.
