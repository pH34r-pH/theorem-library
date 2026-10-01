# `docs/wiki/` map

These pages are the canonical source copied by [`../../.github/workflows/wiki-sync.yml`](../../.github/workflows/wiki-sync.yml). Read the repository [`../../AGENTS.md`](../../AGENTS.md) before changing them.

- `Home.md` and `Getting-Started.md` define the reading and local verification path.
- `Theorem-Map.md` summarizes the dependency/claim chain; [`../../INDEX.md`](../../INDEX.md) remains authoritative for identifiers and source declarations.
- `Formalization-Scope.md` and `Research-Relationship.md` maintain the formal/empirical boundary.
- `Architecture-and-Namespaces.md` documents layout and namespace policy.
- `Verification.md` and `Publication-and-Provenance.md` document exact-source qualification and evidence limits.
- `Contributing-Proofs.md` is the contribution route; `_Sidebar.md` is wiki navigation.

Keep links checkable and summaries tied to repository source. The existing Lean workflow and wiki-sync workflow remain formal/publication integrations; `documentation-hygiene.yml` is the single changed-Markdown/artifact guard.

```sh
git diff --check
lake build TheoremLibrary
```
