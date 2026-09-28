# Publication and provenance

The public repository is the source of truth for promoted reusable mathematics.

## Exact-source qualification

Downstream publication can select an exact 40-character commit on trusted `main`, verify the required formal CI job succeeded for that same source revision, and hash the selected source bytes.

A PR-only success or a successful run on a different SHA is not the same qualification evidence.

## Public-core inventory

`PUBLIC_CORE.md` records what the project currently presents as the reusable exported library. It is a human-facing inventory, while Lean imports and CI provide executable checks.

## Attribution and reuse

The project is Apache-2.0 licensed and includes NOTICE/provenance material. Research consumers should cite the repository plus the stable theorem identifier or specific source declaration they rely on.

## Immutable meaning

Reorganizing a module should not silently change the meaning behind an existing stable identifier. A materially different mathematical statement deserves explicit review and identifier/version treatment rather than relying on a path rename to hide the change.
