# Theorem Library

Public, machine-checkable mathematical foundations for the Domain Scaling research program.

This repository contains the **PUBLIC-CORE** Lean theorem library and the **INFRASTRUCTURE** needed to build and validate it. It is deliberately not the research program's theorem ledger.

## Authority boundary

This repository is authoritative for intrinsic formal facts such as:

- the Lean source of a public theorem;
- whether a declaration exists at a particular commit;
- whether that commit builds under the pinned Lean/mathlib toolchain;
- whether the public proof-validation checks pass.

The private research repository remains authoritative for:

- theorem-ledger lifecycle state and scientific acceptance;
- correspondence between formal statements and informal research claims;
- empirical assumptions and interpretation boundaries;
- experiment dependencies and active research provenance.

A compiling Lean theorem proves the encoded mathematical statement under its assumptions. It does **not** by itself prove that an informal scientific claim was encoded faithfully or that its assumptions hold empirically.

## Current PUBLIC-CORE

The initial public slice concentrates on reusable hypersphere-normalization mathematics that already supports the public educational research thread:

- tangent projection identities;
- norm and normalization derivatives;
- exact radial/tangent derivative anisotropy (`LIB-SPH-002` / `FRM-000020`);
- scale-invariant loss and normalized-step identities (`LIB-SPH-003` / `FRM-000021`);
- positive-scale quotient and radial-memory boundaries (`LIB-SPH-001/005` / `FRM-000023`);
- normalization kernel, range, rank, and singular-value structure (`FRM-000133`);
- pre/post-normalization composition boundaries (`FRM-000149`);
- normalized-loss gradient identities (`FRM-000149`).

The `FRM-*` / `LIB-*` labels are stable cross-repository addresses where available. Their scientific lifecycle/status remains owned by the private theorem ledger; this repository does not duplicate it.

## Layout

```text
DomainScaling/       reusable Lean theorem modules
TheoremLibrary.lean  public library import surface
scripts/             bootstrap and validation infrastructure
lakefile.lean        Lake project definition
lake-manifest.json   pinned dependency manifest
lean-toolchain       pinned Lean toolchain
```

## Development

```bash
bash scripts/bootstrap_mathlib.sh
lake build TheoremLibrary
bash scripts/dev_check.sh
bash scripts/validate_formal.sh
```

The public validation stack performs an ordinary Lean build, independent `leanchecker` validation, a project-source placeholder audit, and a pinned axiom audit. Passing those checks establishes an intrinsic fact about this encoded proof library; it is not a substitute for scientific correspondence review in the private research program.

## Consumers

- `domain-scaling-lab` — private empirical research integration and authoritative theorem ledger; it consumes a pinned theorem-library commit.
- [`research-notes`](https://github.com/pH34r-pH/research-notes) — public educational explanations and links to selected formal checkpoints.

## Disclosure classes

**PUBLIC-CORE:** reusable mathematical results whose disclosure does not expose a sensitive active empirical frontier.

**INFRASTRUCTURE:** build/bootstrap/checking machinery required to independently verify PUBLIC-CORE.

Experiment-specific formal extensions and theorem-ledger context may remain private until they are appropriate for public release.
