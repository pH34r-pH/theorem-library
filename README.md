# Theorem Library

[![Lean](https://github.com/pH34r-pH/theorem-library/actions/workflows/lean.yml/badge.svg)](https://github.com/pH34r-pH/theorem-library/actions/workflows/lean.yml)
[![License](https://img.shields.io/github/license/pH34r-pH/theorem-library)](LICENSE)

<p align="center">
  <img src="docs/assets/hero.webp" alt="Theorem Library — formal mathematics and reusable theorem graph" width="100%">
</p>

**Machine-checkable mathematics extracted from an empirical research program.**

Theorem Library contains reusable Lean results that emerged while studying neural representations and computation. The current public core focuses on normalization and hyperspherical geometry: what normalization preserves, what it removes, the exact structure of its derivative, and which local conclusions survive composition with surrounding computation.

The goal is independent inspectability: the mathematical layer should build and make sense without requiring private experiments or research infrastructure.

## What is in the public core

The current results cover:

- derivatives of the norm and vector normalization;
- exact radial/tangent behavior;
- kernel, range, rank, and singular-value structure;
- scale-invariant loss and gradient consequences;
- the positive-scale quotient / radial-memory boundary;
- composition conditions that preserve or break local radial/tangent conclusions.

The dependency shape is:

```text
norm derivative
 -> normalization derivative
 -> radial/tangent geometry
 -> spectral/composition/gradient consequences
```

Use [INDEX.md](INDEX.md) for stable identifiers, plain-language statements, and source links. [PUBLIC_CORE.md](PUBLIC_CORE.md) lists the exported modules.

## Verify locally

```sh
bash scripts/bootstrap_mathlib.sh
lake build TheoremLibrary
bash scripts/dev_check.sh
bash scripts/validate_formal.sh
lake env lean Mutate.lean
```

The repository pins Lean and Mathlib inputs through `lean-toolchain` and `lake-manifest.json`.

A successful build establishes that the encoded statements follow from their encoded assumptions in that formal environment. It does **not** establish that a particular trained model satisfies those assumptions or that a theorem explains an empirical observation.

## Research relationship

[Research Notes](https://github.com/pH34r-pH/research-notes) explains why each promoted theorem mattered to the experiments and what stronger conclusion it does not justify.

Stable `LIB-*` and `FRM-*` identifiers let those references survive source-module reorganization.

```text
research question -> mathematical subclaim -> Lean proof
                                           |
                                           v
                                  stable theorem ID
                                           |
                                           v
                            public research explanation
```

Read the [Wiki](https://github.com/pH34r-pH/theorem-library/wiki) for the theorem map, formalization scope, namespace architecture, verification model, and publication/provenance contract.

## Repository map

- `TheoremLibrary/` — reusable theorem modules.
- `TheoremLibrary.lean` — library import surface.
- `INDEX.md` — stable identifiers and human-readable theorem map.
- `PUBLIC_CORE.md` — exported-module inventory.
- `NAMESPACE.md` — namespace/contribution boundary.
- `docs/wiki/` — canonical source for the GitHub Wiki.
- `scripts/` — bootstrap and independent validation.
- `lakefile.lean`, `lake-manifest.json`, `lean-toolchain` — pinned environment.

Scoped maintainer maps and focused validation commands live in [`AGENTS.md`](AGENTS.md) and the directory-level maps linked there.

## Contributing and citation

Read [CONTRIBUTING.md](CONTRIBUTING.md) and [NAMESPACE.md](NAMESPACE.md) before proposing exported mathematics. Research use can cite [CITATION.cff](CITATION.cff) plus the stable theorem identifier/declaration used.

Licensed under Apache-2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
