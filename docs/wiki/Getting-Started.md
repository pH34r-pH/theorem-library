# Getting started

The repository pins both Lean and Mathlib inputs.

## Bootstrap and build

```sh
bash scripts/bootstrap_mathlib.sh
lake build TheoremLibrary
bash scripts/dev_check.sh
bash scripts/validate_formal.sh
```

The ordinary library import surface is `TheoremLibrary.lean`; reusable modules live under the `TheoremLibrary.*` namespace.

## What a green build means

A green build and validation pass mean the checked theorem statements type-check in the pinned environment and satisfy the repository's structural/public-core checks.

That is formal evidence for the encoded mathematics. It is not evidence about an empirical model unless a separate argument establishes that the model satisfies the assumptions.

## Read before editing

Use [INDEX.md](https://github.com/pH34r-pH/theorem-library/blob/main/INDEX.md) for plain-language theorem mapping, [PUBLIC_CORE.md](https://github.com/pH34r-pH/theorem-library/blob/main/PUBLIC_CORE.md) for the exported inventory, and [NAMESPACE.md](https://github.com/pH34r-pH/theorem-library/blob/main/NAMESPACE.md) for namespace/contribution boundaries.
