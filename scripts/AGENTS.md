# `scripts/` map

These scripts implement the repository's existing formal validation path. Read the repository [`../AGENTS.md`](../AGENTS.md) and [`../docs/wiki/Verification.md`](../docs/wiki/Verification.md) first.

- `bootstrap_mathlib.sh` fetches the direct Mathlib cache closure listed for the current formal layer; keep the list synchronized with direct imports.
- `dev_check.sh` builds the requested target, defaulting to `TheoremLibrary`.
- `validate_formal.sh` builds, runs `leanchecker`, rejects `sorry`/`admit`, and builds the pinned axiom-audit tool with the permitted axiom list.
- `docs_hygiene.py` / `test_docs_hygiene.py` check changed living-document names, actual Git rename destinations, and incidental artifacts; the workflow sends changed living Markdown to pinned style/link tools.
- `validate_mutation_fixture_report.py` checks captured upstream mutation coordinates against the report's embedded fixture source; it does not run or replace the upstream mutation engine.

Do not replace these with an unpinned local check or add another custom CI guard. Keep external tool revisions and source checks explicit.

```sh
bash scripts/bootstrap_mathlib.sh
bash scripts/dev_check.sh
bash scripts/validate_formal.sh
python scripts/test_docs_hygiene.py
```
