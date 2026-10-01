# Working in Theorem Library

Read [`README.md`](README.md), [`CONTRIBUTING.md`](CONTRIBUTING.md), [`INDEX.md`](INDEX.md), [`PUBLIC_CORE.md`](PUBLIC_CORE.md), and [`NAMESPACE.md`](NAMESPACE.md) before changing the formal core.

## Repository map

| Boundary | Responsibility | Read with |
| --- | --- | --- |
| `TheoremLibrary/` | Reusable Lean declarations under the stable `TheoremLibrary.*` namespace. | [`TheoremLibrary/AGENTS.md`](TheoremLibrary/AGENTS.md) |
| `TheoremLibrary.lean` | Public import surface for the current core. | [`PUBLIC_CORE.md`](PUBLIC_CORE.md) |
| `INDEX.md` | Human-readable theorem statements, stable identifiers, source files, and Research Notes links. | [`INDEX.md`](INDEX.md) |
| `PUBLIC_CORE.md` / `NAMESPACE.md` | Export inventory and formal/empirical contribution boundary. | [`PUBLIC_CORE.md`](PUBLIC_CORE.md), [`NAMESPACE.md`](NAMESPACE.md) |
| `scripts/` | Pinned bootstrap, development build, formal audits, and changed-document/artifact validation. | [`scripts/AGENTS.md`](scripts/AGENTS.md) |
| `docs/wiki/` | Canonical GitHub Wiki source for formalization scope, theorem map, verification, and provenance. | [`docs/wiki/AGENTS.md`](docs/wiki/AGENTS.md) |
| `lakefile.lean`, `lake-manifest.json`, `lean-toolchain` | Pinned Lean/Mathlib build environment. | [`docs/wiki/Verification.md`](docs/wiki/Verification.md) |
| `.github/workflows/` | Existing Lean qualification and wiki-sync entrypoints. | [`.github/workflows/lean.yml`](.github/workflows/lean.yml) |

## Architecture and data flow

```text
Mathlib + pinned Lean/Mathlib environment
        -> TheoremLibrary.Geometry.Sphere modules
        -> TheoremLibrary.lean public imports
        -> lake build / leanchecker / axiom audit
        -> stable INDEX.md/PUBLIC_CORE.md descriptions
        -> Research Notes explanation (separate repository)
```

The dependency direction is foundational projection and norm calculus, then normalization derivative, radial/tangent consequences, spectral/gradient/composition results, and radial-memory consequences. The formal build checks encoded statements under encoded assumptions; it does not validate empirical data, model assumptions, novelty, or scientific interpretation.

## Invariants and change routing

- Keep reusable mathematics under `TheoremLibrary.*`; do not import experiment names, empirical assumptions, or private lifecycle state into the public namespace.
- Keep imports narrow and dependency direction intelligible; do not use convenience imports to conceal provenance or create cycles.
- Stable `LIB-*`/`FRM-*` identifiers preserve conceptual continuity. A materially different statement needs explicit review and identifier/version treatment, not a silent path rename.
- Do not add `sorry` or `admit`; the formal validation script audits all project Lean sources.
- Update `INDEX.md` and, when appropriate, `PUBLIC_CORE.md` for exported results. Update the linked Research Notes checkpoint only when the external mathematical/publication evidence exists.

## Focused validation

Run from the repository root:

```sh
git diff --check
lake build TheoremLibrary
bash scripts/dev_check.sh
bash scripts/validate_formal.sh
python scripts/test_docs_hygiene.py
```

The existing formal CI source is [`.github/workflows/lean.yml`](.github/workflows/lean.yml), and [`.github/workflows/documentation-hygiene.yml`](.github/workflows/documentation-hygiene.yml) is the single changed-Markdown/artifact guard. Do not add another guard while Fleet #1032, DSL #586, and Portfolio #84 are under coherence review.
