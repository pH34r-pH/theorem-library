# Theorem Library

Theorem Library contains machine-checkable mathematical results that emerged from my research into neural representations and computation. The current public collection focuses on normalization and hyperspherical geometry: what normalization preserves, what it removes, how its derivative behaves, and which of those local properties survive composition with other operations.

The proofs are written in Lean and build against a pinned Lean/Mathlib environment. They are intended to make the mathematical parts of the research independently inspectable without requiring the surrounding experiments or research infrastructure.

## Current results

The public library currently includes proofs covering:

- the derivative of vector normalization;
- exact radial and tangent behavior under that derivative;
- its kernel, range, rank, and singular values;
- consequences for scale-invariant losses and gradients;
- what information positive rescaling loses at a normalization boundary;
- where radial/tangent conclusions do and don't survive composition with surrounding computation.

These results support the normalization and hypersphere thread in my [Research Notes](https://github.com/pH34r-pH/research-notes), where I explain why each result mattered to the experiments and what stronger conclusions it doesn't justify.

See [INDEX.md](INDEX.md) for a human-readable map from stable theorem identifiers to plain-language statements and Lean source.

## How the pieces fit together

The Lean modules form a small dependency chain rather than a collection of unrelated theorem files:

`norm derivative → normalization derivative → radial/tangent geometry → spectral/composition/gradient consequences`

The [PUBLIC-CORE inventory](PUBLIC_CORE.md) lists the currently exported modules, while the source under `TheoremLibrary/` contains the proofs themselves.

Stable `LIB-*` and `FRM-*` identifiers are used where a result also appears elsewhere in the research, so the same theorem can be referenced even if its Lean module is later reorganized.

## Repository structure

```text
TheoremLibrary/       reusable Lean theorem modules
TheoremLibrary.lean   library import surface
INDEX.md              human-readable theorem index
PUBLIC_CORE.md        exported-module inventory
scripts/              bootstrap and validation tools
lakefile.lean         Lake project definition
lake-manifest.json    pinned dependencies
lean-toolchain        pinned Lean toolchain
```

Reusable public mathematics lives under the `TheoremLibrary.*` namespace. [NAMESPACE.md](NAMESPACE.md) documents the namespace boundary for contributors.

## Fleet source qualification

Private Fleet selects a full 40-character theorem-library commit SHA on the trusted `main` history. The source checkout at that SHA is the publication input: `TheoremLibrary/**`, `TheoremLibrary.lean`, `lakefile.lean`, `lean-toolchain`, `lake-manifest.json` and validation/bootstrap scripts. Fleet pins the checkout and hashes the exact used bytes alongside Portfolio and other research source SHAs in its private publication receipt.

The public `lean` workflow's stable required job is `formal-proof`. It now runs for **every main push**, including docs-only commits, and on proof-affecting PR changes. It uses a GitHub-hosted runner with `contents: read`, the pinned Lean/Mathlib inputs, `scripts/bootstrap_mathlib.sh`, `lake build TheoremLibrary`, and `scripts/validate_formal.sh`. Fleet requires a completed successful **main push** run and that named job on the same exact source SHA. A missing, skipped, pending, canceled, failed or PR-only run cannot qualify a candidate. Manual dispatch remains a diagnostic/retry path but does not replace the exact-main gate.

A successful formal build proves the encoded statements under their stated formal assumptions. It says nothing by itself about empirical models. Fleet #177 owns automatic intake, additional source pins and final artifact digest; protected Azure publication stays in private Fleet.

## Verification

The repository pins its Lean and Mathlib dependencies and validates the public library through an ordinary Lean build plus independent proof and source checks.

To build it locally:

```bash
bash scripts/bootstrap_mathlib.sh
lake build TheoremLibrary
bash scripts/dev_check.sh
bash scripts/validate_formal.sh
```

A successful build establishes that the encoded mathematical statements follow from their stated assumptions in the pinned formal environment. Whether a theorem's assumptions describe a particular trained model is a separate scientific question; those connections are discussed in the Research Notes rather than encoded into the theorem itself.
