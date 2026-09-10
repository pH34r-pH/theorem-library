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

## Layout

```text
DomainScaling/       reusable Lean mathematics
DomainScaling.lean   public library import surface
scripts/             bootstrap and validation infrastructure
lakefile.lean        Lake project definition
lake-manifest.json   pinned dependency manifest
lean-toolchain       pinned Lean toolchain
```

## Development

```bash
bash scripts/bootstrap_mathlib.sh
lake build DomainScaling
bash scripts/dev_check.sh
bash scripts/validate_formal.sh
```

The library intentionally uses stable declaration/ontology identifiers in theorem documentation where available. Those identifiers permit the private theorem ledger and public educational notes to refer to the same formal object without duplicating ledger state here.

## Consumers

- `domain-scaling-lab` — private empirical research integration and authoritative theorem ledger.
- `research-notes` — public educational explanations and links to selected formal checkpoints.

## Disclosure classes

**PUBLIC-CORE:** reusable mathematical results whose disclosure does not expose a sensitive active empirical frontier.

**INFRASTRUCTURE:** build/bootstrap/checking machinery required to independently verify PUBLIC-CORE.

Experiment-specific formal extensions may remain private until they are appropriate for public release.
