# `scripts/` map

These scripts implement the repository's existing formal validation path. Read the repository [`../AGENTS.md`](../AGENTS.md) and [`../docs/wiki/Verification.md`](../docs/wiki/Verification.md) first.

- `bootstrap_mathlib.sh` fetches the direct Mathlib cache closure listed for the current formal layer; keep the list synchronized with direct imports.
- `dev_check.sh` builds the requested target, defaulting to `TheoremLibrary`.
- `validate_formal.sh` builds, runs `leanchecker`, rejects `sorry`/`admit`, and builds the pinned axiom-audit tool with the permitted axiom list.
- `docs_hygiene.py` / `test_docs_hygiene.py` check changed living-document names, actual Git rename destinations, and incidental artifacts; the workflow sends changed living Markdown to pinned style/link tools.
- `validate_applicability.py` checks the FRM-000133 proof pin, synthetic boundary cases, and unmeasured study handoff during formal validation.
- `validate_public_references.py` checks the applicability records and renders the inputs for `fixtures/PublicTheoremInventory.lean`. Lean compares them with the named theorems and their defining modules in the compiled public library.
- `formal_common.sh` checks the selected Lean version and propagates stage diagnostics. `test_formal_scripts.py` uses offline tool stubs to check the entrypoints and their cache inventory.
- `validate_mutation_fixture_report.py` checks captured upstream mutation coordinates against the report's embedded fixture source; it does not run or replace the upstream mutation engine.
- `fixtures/ApplicabilityBoundary.lean` proves counterexamples when a unit premise is weakened. The formal validation script compiles it against the public library, and the proof candidate retains it with the mutation fixture and report.
- `stage_proof_candidate.py` packages the checked source and public Lean outputs after formal validation. `test_proof_candidate.py` checks the archive and its member digests with isolated Git fixtures.

Do not replace these with an unpinned local check or add another custom CI guard. Keep external tool revisions and source checks explicit.

```sh
bash scripts/bootstrap_mathlib.sh
bash scripts/dev_check.sh
bash scripts/validate_formal.sh
python scripts/test_docs_hygiene.py
python scripts/test_formal_scripts.py
```
