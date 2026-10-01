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

## Bounded mutation specification baseline

`Mutate.lean` is a small repository-local harness, not an upstream project or
an independently released mutation-testing framework. It is versioned with
Theorem Library and is covered by this repository's Apache-2.0 license. The
harness uses the pinned Lean toolchain (`leanprover/lean4:v4.34.0-rc2`) and the
Mathlib revision pinned in `lakefile.lean`; Lean elaboration and the kernel are
the final proof verifier.

The runner exercises two concrete projection properties, then records a
survivor classification and checks a mixed-direction counterexample. It emits
`reports/mutation-baseline.json` using Mutation Testing Elements report
`schemaVersion` 2, compatible with the pinned `mutation-testing-report-schema`
3.9.0 source from the Stryker Mutation Testing Elements project
([Apache-2.0](https://github.com/stryker-mutator/mutation-testing-elements)).
The runner is only a bounded adapter around Lean and that report contract; it
does not introduce a replacement mutation framework or make a mutation score
gate a mathematical claim.

Run locally with:

```sh
bash scripts/mutation_baseline.sh --write
bash scripts/mutation_baseline.sh --check
```

The committed report intentionally retains both killed and survived examples:
the `specification-gap` survivor passes the radial/tangent baseline but fails
the kernel-checked mixed-direction additivity property, while the
`equivalent-noise` survivor is propositionally equivalent to the baseline.
These are specification-feedback categories for this finite witness suite,
not claims about arbitrary recurrences or trained models. Plausible/LSpec are
not required by this bounded deterministic baseline; generated examples remain
a future extension rather than silently trusted evidence.

## CI qualification

The stable formal-proof CI job runs against exact public source revisions. Downstream private publication/qualification can require a successful main-branch run on the same exact commit before consuming that source.

## What verification excludes

A formal build does not:

- validate empirical data;
- prove a neural network realizes the formal assumptions;
- establish novelty;
- establish that a theorem is the best explanation of an observation.

Those are separate scientific/review tasks.
