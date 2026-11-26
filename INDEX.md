# Theorem index

This index is the human-readable entry point to the public Lean library. It describes what each stable result says and links to the source that proves it. Research-specific interpretation lives in the [Research Notes](https://github.com/pH34r-pH/research-notes).

Each applicability record pins the Lean sources and states the conditions and scope of the indexed result. Its study handoff records applicability as unmeasured in the theorem library. Where a relevant public Research Notes checkpoint exists, the record links it. A `null` checkpoint marks a result with no specific public handoff.

## Foundations of normalization

### FRM-000001 — derivative of exact normalization away from zero

For nonzero `x`, the Fréchet derivative of `x ↦ (1 / ‖x‖) • x` is the tangent projector at the unit direction `x / ‖x‖`, scaled by the inverse radius. This statement concerns the derivative at a single point.

[Applicability record](docs/applicability/frm-000001.json) · [Lean source](TheoremLibrary/Geometry/Sphere/Normalization.lean) · [Research checkpoint](https://github.com/pH34r-pH/research-notes/blob/main/reference/formal-methods/checkpoints.md#lib-sph-002--frm-000020--normalization-derivative-anisotropy)

### FRM-000002 — radial and tangent projection identities

The map `v ↦ v − ⟨u, v⟩u` sends `u` to zero when `u` has unit length. It fixes `v` when `v` is orthogonal to `u`.

[Applicability record](docs/applicability/frm-000002.json) · [Lean source](TheoremLibrary/Geometry/Sphere/Projection.lean) · [Nonunit counterexample](scripts/fixtures/ApplicabilityBoundary.lean)

### FRM-000003 — derivative of the norm at unit radius

At a unit vector `u`, the Fréchet derivative of the real inner-product norm sends `v` to `⟨u, v⟩`.

[Applicability record](docs/applicability/frm-000003.json) · [Lean source](TheoremLibrary/Geometry/Sphere/NormDerivative.lean)

### FRM-000004 — derivative of the reciprocal norm at unit radius

At a unit vector `u`, the Fréchet derivative of the reciprocal norm sends `v` to `−⟨u, v⟩`.

[Applicability record](docs/applicability/frm-000004.json) · [Lean source](TheoremLibrary/Geometry/Sphere/Normalization.lean)

### FRM-000005 — derivative of normalization at unit radius

At a unit vector `u`, the Fréchet derivative of normalization is the unscaled tangent projector `v ↦ v − ⟨u, v⟩u`.

[Applicability record](docs/applicability/frm-000005.json) · [Lean source](TheoremLibrary/Geometry/Sphere/Normalization.lean) · [Nonunit counterexample](scripts/fixtures/ApplicabilityBoundary.lean) · [Research checkpoint](https://github.com/pH34r-pH/research-notes/blob/main/reference/formal-methods/checkpoints.md#lib-sph-002--frm-000020--normalization-derivative-anisotropy)

### FRM-000006 — radial annihilation by the normalization derivative

At nonzero `x`, the derivative of normalization sends the radial direction `x` to zero.

[Applicability record](docs/applicability/frm-000006.json) · [Lean source](TheoremLibrary/Geometry/Sphere/Normalization.lean) · [Research checkpoint](https://github.com/pH34r-pH/research-notes/blob/main/reference/formal-methods/checkpoints.md#lib-sph-002--frm-000020--normalization-derivative-anisotropy)

### FRM-000007 — tangent scaling by the normalization derivative

At nonzero `x`, the derivative of normalization sends an orthogonal perturbation `v` to `(1 / ‖x‖) • v`.

[Applicability record](docs/applicability/frm-000007.json) · [Lean source](TheoremLibrary/Geometry/Sphere/Normalization.lean) · [Research checkpoint](https://github.com/pH34r-pH/research-notes/blob/main/reference/formal-methods/checkpoints.md#lib-sph-002--frm-000020--normalization-derivative-anisotropy)

## Hypersphere normalization

### LIB-SPH-002 / FRM-000020 — normalization derivative anisotropy

For a nonzero vector, normalization removes infinitesimal motion in the radial direction and scales tangent motion by inverse radius. At unit radius, tangent motion is preserved to first order.

[Applicability record](docs/applicability/frm-000020.json)

**Source:** [Anisotropy.lean](TheoremLibrary/Geometry/Sphere/Anisotropy.lean) · [Normalization.lean](TheoremLibrary/Geometry/Sphere/Normalization.lean)

**Research explanation:** [Formal checkpoint](https://github.com/pH34r-pH/research-notes/blob/main/reference/formal-methods/checkpoints.md#lib-sph-002--frm-000020--normalization-derivative-anisotropy)

### LIB-SPH-003 / FRM-000021 — scale-invariant loss geometry

For differentiable losses composed through normalization, first-order radial sensitivity vanishes. Related results characterize normalized tangent updates and their angular scaling.

[Applicability record](docs/applicability/frm-000021.json)

**Source:** [ScaleInvariantLoss.lean](TheoremLibrary/Geometry/Sphere/ScaleInvariantLoss.lean) · [NormalizationGradient.lean](TheoremLibrary/Geometry/Sphere/NormalizationGradient.lean)

**Research explanation:** [Formal checkpoint](https://github.com/pH34r-pH/research-notes/blob/main/reference/formal-methods/checkpoints.md#lib-sph-003--frm-000021--scale-invariant-loss-geometry)

### LIB-SPH-001/005 / FRM-000023 — positive-scale quotient and radial-memory boundary

Positive rescalings of the same nonzero proposal normalize to the same state. Once that radius has been erased, deterministic downstream computation that receives only the normalized state cannot determine which positive rescaling produced it.

This result is deliberately narrower than saying that a recurrent model cannot preserve information previously associated with radius; upstream computation may move such information into direction before normalization.

[Applicability record for both LIB references](docs/applicability/frm-000023.json)

**Source:** [RadialMemory.lean](TheoremLibrary/Geometry/Sphere/RadialMemory.lean)

**Research explanation:** [Formal checkpoint](https://github.com/pH34r-pH/research-notes/blob/main/reference/formal-methods/checkpoints.md#lib-sph-001005--frm-000023--positive-scale-quotient-and-radial-memory-boundary)

### FRM-000133 — normalization spectrum

In a finite-dimensional real inner-product space, at `x ≠ 0`, the derivative of the exact map `x ↦ (1 / ‖x‖) • x` has a radial zero mode and inverse-radius gain on directions orthogonal to `x`. The result concerns one local derivative. The library characterizes its kernel, range, rank, and singular values exactly.

The [applicability record](docs/applicability/frm-000133.json) pins the declaration and includes a reproducible binary64 example. At norm `ε/2` the exact map retains tangent gain, while an illustrative cutoff implementation stays constant. The example also checks a masked row. Empirical applicability stays unmeasured until the study records its operator revision, dtype, epsilon and mask policies, and the corresponding population counts.

**Source:** [NormalizationSpectrum.lean](TheoremLibrary/Geometry/Sphere/NormalizationSpectrum.lean)

**Research explanation:** [Formal checkpoint](https://github.com/pH34r-pH/research-notes/blob/main/reference/formal-methods/checkpoints.md#frm-000133--normalization-spectrum)

### FRM-000149 — composition and gradient boundaries

These results describe where the radial/tangent properties of normalization survive composition with surrounding maps and give exact gradient identities for differentiable normalized losses.

Their main purpose is to stop a local theorem about normalization from being applied automatically to an entire learned recurrence.

[Applicability record](docs/applicability/frm-000149.json)

**Source:** [NormalizationComposition.lean](TheoremLibrary/Geometry/Sphere/NormalizationComposition.lean) · [NormalizationGradient.lean](TheoremLibrary/Geometry/Sphere/NormalizationGradient.lean)

**Research explanation:** [Formal checkpoint](https://github.com/pH34r-pH/research-notes/blob/main/reference/formal-methods/checkpoints.md#frm-000149--composition-and-gradient-boundaries)

## Supporting modules

[Projection.lean](TheoremLibrary/Geometry/Sphere/Projection.lean) and [NormDerivative.lean](TheoremLibrary/Geometry/Sphere/NormDerivative.lean) provide supporting identities used by the normalization results.

The exact dependency and import surface is available from [TheoremLibrary.lean](TheoremLibrary.lean) and the individual module imports. [PUBLIC_CORE.md](PUBLIC_CORE.md) lists the modules currently included in the public library.
