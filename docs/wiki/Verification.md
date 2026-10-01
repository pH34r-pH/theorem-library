# Verification

Verification has two layers: Lean's kernel/type-checking path and repository-level structural validation.

## Pinned environment

The repository pins the Lean toolchain and Mathlib dependency state. Rebuilding against those inputs prevents “it compiles on whatever latest dependency I have” from becoming the proof contract.

## Main build

```sh
lake build TheoremLibrary
```

This checks the exported library and its dependencies.

## Validation scripts

The bootstrap/dev/formal scripts add repository-specific checks around source layout, exported declarations, and the intended public-core contract.

## Bounded mutation specification fixture

`Mutate.lean` is a small repository-local Lean fixture, covered by this
repository's Apache-2.0 license. It imports the production
`tangentProject` directly and proves radial, tangent, and mixed-direction
properties; it does not duplicate or replace the library definition.

The intended external runner is [jubnzv/Mutate.lean](https://github.com/jubnzv/Mutate.lean),
whose README requires Lean `>=4.28`, compatible with this repository's pinned
`leanprover/lean4:v4.34.0-rc2`. The tested upstream commit is
`b8a4d402cd1cf605aaac8a5494a6eea604d406c3` (2026-09-11). Its compiler-backed
classification distinguishes `killed`, `survived`, and `stillborn`; failed
elaboration is not treated as a proposition being false.

The upstream repository currently has no tracked `LICENSE` file, no declared
SPDX license in GitHub metadata, and no release/tag. Therefore this repository
does not vendor it, download it in CI, or claim issue #11 complete. A local
checkout can be tested with:

```sh
MUTATE_LEAN=/path/to/Mutate.lean/Mutate.lean
lake env lean --run "$MUTATE_LEAN" --include-def projectionFixture --ops lit Mutate.lean
lake env lean --run "$MUTATE_LEAN" --include-def tangentProject \
  --no-ops lit,ident,flip,args,body \
  TheoremLibrary/Geometry/Sphere/Projection.lean
```

The observed upstream result is `killed=1 survived=0 stillborn=0`, with
`projection_fixture_mixed_additivity` identifying the strengthened invariant.
Running the actual production definition separately gave `killed=2
survived=0 stillborn=2`, with `tangentProject_radial` identified for the
killed mutations. The captured machine-readable report is
`reports/mutation-upstream-fixture.json`; it records the upstream commit and
command. It intentionally omits coverage fields because the upstream tool
does not measure test coverage for this run.
The remaining blocker is upstream usage rights, not Lean compatibility.

## CI qualification

The stable formal-proof CI job runs against exact public source revisions. Downstream private publication/qualification can require a successful main-branch run on the same exact commit before consuming that source.

## What verification excludes

A formal build does not:

- validate empirical data;
- prove a neural network realizes the formal assumptions;
- establish novelty;
- establish that a theorem is the best explanation of an observation.

Those are separate scientific/review tasks.
