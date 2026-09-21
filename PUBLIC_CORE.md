# Public module inventory

The public library currently covers one connected mathematical thread: vector normalization and its consequences. The modules progress from elementary projection identities through the normalization derivative, then into anisotropy, spectral structure, scale-invariant losses, radial-memory boundaries, composition, and gradients.

## Modules

- `TheoremLibrary.Geometry.Sphere.Projection` — radial/tangent projection identities on a unit direction.
- `TheoremLibrary.Geometry.Sphere.NormDerivative` — Fréchet derivative of the norm away from zero.
- `TheoremLibrary.Geometry.Sphere.Normalization` — derivative of vector normalization and its radial/tangent action.
- `TheoremLibrary.Geometry.Sphere.Anisotropy` — exact separation between radial and tangent first-order gain.
- `TheoremLibrary.Geometry.Sphere.ScaleInvariantLoss` — consequences of normalization for differentiable losses and tangent updates.
- `TheoremLibrary.Geometry.Sphere.RadialMemory` — positive-scale equivalence and the information boundary created by normalization.
- `TheoremLibrary.Geometry.Sphere.NormalizationSpectrum` — kernel, range, rank, and singular values of the normalization derivative.
- `TheoremLibrary.Geometry.Sphere.NormalizationComposition` — what radial/tangent conclusions survive composition with surrounding computation.
- `TheoremLibrary.Geometry.Sphere.NormalizationGradient` — exact gradients and update identities for losses composed with normalization.

See [INDEX.md](INDEX.md) for plain-language theorem descriptions, stable identifiers, and links into the Research Notes.

## Verification infrastructure

The repository includes the pinned Lean/Mathlib environment and the scripts required to build and independently validate these modules:

- `lake-manifest.json` and `lean-toolchain` pin the formal environment;
- `scripts/bootstrap_mathlib.sh` prepares the required Mathlib cache;
- `scripts/dev_check.sh` provides the normal development check;
- `scripts/validate_formal.sh` performs the additional proof/source validation used by CI;
- `.github/workflows/lean.yml` runs validation on GitHub Actions.

The public module set can grow as additional reusable results become stable enough to stand independently of the experiments that produced them.
