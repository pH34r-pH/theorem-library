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

Use Bash, Git, Python 3, and Lake with the committed `lean-toolchain` and
`lake-manifest.json`. The scripts resolve the repository root from their own
path, so an absolute invocation also works from another directory.

- `bash scripts/bootstrap_mathlib.sh` verifies the selected Lean version and
  fetches the transitive cache for the direct Mathlib imports.
- `bash scripts/dev_check.sh` builds `TheoremLibrary`. Optional arguments are
  passed to `lake build`.
- `bash scripts/validate_formal.sh` checks applicability and public names,
  builds the library, runs leanchecker, verifies the local mutation fixture and
  report, scans for placeholders, and runs the pinned axiom audit.
- `python scripts/test_formal_scripts.py` uses offline tool stubs to exercise
  wrong and missing prerequisites and check that failure stops each stage.

Each shell entrypoint reports the stage and returns a nonzero result when its
tool fails. The real proof run and the offline script fixtures supply separate
evidence. The mutation check covers the retained fixture and report.

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
That captured mutation targets only the fixture wrapper's artificial zero
coefficient; it does not mutate production `tangentProject`. No before-
strengthening survivor run was recorded, so this is not a before/after mutation
score or a general theorem about mixed directions.
Running the actual production definition separately gave `killed=2
survived=0 stillborn=2`, with `tangentProject_radial` identified for the
killed mutations. The captured machine-readable report is
`reports/mutation-upstream-fixture.json`; it records the upstream commit and
command. It intentionally omits coverage fields because the upstream tool
does not measure test coverage for this run. Formal validation also checks that
the report's source-derived mutation range is in bounds and extracts the
declared original token. The upstream execution was developer-captured; CI
checks the Lean fixture and report integrity but does not install or rerun the
unlicensed upstream tool.
The remaining blocker is upstream usage rights, not Lean compatibility.

## CI qualification

The stable formal-proof CI job runs against exact public source revisions. Downstream private publication/qualification can require a successful main-branch run on the same exact commit before consuming that source.

For a retained proof candidate, run the Lean workflow on `main` with the
`retain_proof_candidate` input enabled. The workflow recompiles the pinned
library in a fresh runner, checks the public declarations and axioms, and
packages the checked Git sources and compiled public modules. The bundle
includes a receipt with each member's SHA-256, the exact source revision,
the observed Lean version, and the locked Mathlib revision.

```sh
gh workflow run lean.yml -R pH34r-pH/theorem-library --ref main \
  -F retain_proof_candidate=true
```

Download the `theorem-proof` artifact for the completed run and verify it using
the exact source SHA shown for that run.

```sh
gh attestation verify theorem-proof.tar.gz -R pH34r-pH/theorem-library \
  --signer-workflow pH34r-pH/theorem-library/.github/workflows/lean.yml \
  --source-ref refs/heads/main --source-digest "$REVIEWED_PROOF_SHA"
```

The attestation binds the bundle to the workflow and reviewed revision.
Publication of a versioned release is a separate owner decision. See the
[GitHub artifact attestation guide](https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/use-artifact-attestations).

## What verification excludes

A formal build does not:

- validate empirical data;
- prove a neural network realizes the formal assumptions;
- establish novelty;
- establish that a theorem is the best explanation of an observation.

Those are separate scientific/review tasks.
