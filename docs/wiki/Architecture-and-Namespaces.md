# Architecture and namespaces

The repository is a small Lean library with an intentionally stable public surface.

## Layout

- `TheoremLibrary/` — reusable theorem modules.
- `TheoremLibrary.lean` — top-level import surface.
- `INDEX.md` — stable identifiers and human-readable statements.
- `PUBLIC_CORE.md` — exported module inventory.
- `NAMESPACE.md` — namespace and contribution boundary.
- `scripts/` — bootstrap and independent validation checks.
- `lakefile.lean`, `lake-manifest.json`, `lean-toolchain` — pinned build environment.

## Namespace rule

Reusable public mathematics lives under `TheoremLibrary.*`. Temporary research scaffolding or private proof exploration should not leak into the public namespace merely to make a local experiment compile.

## Dependency shape

Modules are organized so foundational calculus/geometry results support higher-level consequences. Avoid circular “convenience imports” that make theorem provenance difficult to inspect.

## Stable identifiers

Stable `LIB-*` and `FRM-*` identifiers decouple research references from module paths. Source organization can improve without forcing every notebook or ledger entry to change its conceptual identifier.
