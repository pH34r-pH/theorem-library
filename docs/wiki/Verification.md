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

## CI qualification

The stable formal-proof CI job runs against exact public source revisions. Downstream private publication/qualification can require a successful main-branch run on the same exact commit before consuming that source.

## What verification excludes

A formal build does not:

- validate empirical data;
- prove a neural network realizes the formal assumptions;
- establish novelty;
- establish that a theorem is the best explanation of an observation.

Those are separate scientific/review tasks.
