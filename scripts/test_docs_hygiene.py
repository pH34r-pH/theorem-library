import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from copy import deepcopy

from docs_hygiene import changed_files, check_paths
from validate_applicability import RECORD, ROOT, validate, validate_indexed_scope
from validate_public_references import _load_records, validate as validate_public_references


class DocumentationHygieneTests(unittest.TestCase):
    def test_cli_code_only_paths_emit_no_markdown_and_still_run_guard(self):
        script = Path(__file__).with_name("docs_hygiene.py")
        selected = subprocess.run(
            [sys.executable, str(script), "--paths", "src/module.py", "--list-living-docs"],
            check=True, text=True, stdout=subprocess.PIPE,
        )
        self.assertEqual("", selected.stdout)
        guarded = subprocess.run(
            [sys.executable, str(script), "--paths", "src/module.py"],
            check=True, text=True, stdout=subprocess.PIPE,
        )
        self.assertIn("1 changed path(s)", guarded.stdout)

    def test_cache_is_rejected_under_evidence(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.assertTrue(check_paths(root, ["docs/evidence/cache/result.json"]))

    def test_issue_number_only_living_name_is_rejected_and_architecture_is_allowed(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.assertEqual([], check_paths(root, ["docs/architecture.md"], {"docs/architecture.md"}))
            self.assertTrue(check_paths(root, ["docs/issue-123.md"], {"docs/issue-123.md"}))

    def test_git_rename_destination_is_checked(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            def git(*args):
                return subprocess.run(["git", *args], cwd=root, check=True,
                                      text=True, stdout=subprocess.PIPE,
                                      stderr=subprocess.PIPE).stdout.strip()
            git("init", "--quiet")
            git("config", "user.email", "docs@example.invalid")
            git("config", "user.name", "Docs Test")
            (root / "docs").mkdir()
            (root / "docs/guide.md").write_text("# Guide\n", encoding="utf-8")
            git("add", "docs/guide.md")
            git("commit", "--quiet", "-m", "initial")
            base = git("rev-parse", "HEAD")
            git("mv", "docs/guide.md", "docs/issue-123.md")
            git("commit", "--quiet", "-m", "rename")
            changed, new_paths = changed_files(root, base)
            self.assertIn("docs/issue-123.md", changed)
            self.assertIn("docs/issue-123.md", new_paths)
            self.assertTrue(check_paths(root, changed, new_paths))


class ApplicabilityTests(unittest.TestCase):
    def setUp(self):
        self.record = json.loads((ROOT / RECORD).read_text(encoding="utf-8"))

    def test_pinned_proof_and_synthetic_active_cutoff_and_masked_rows(self):
        gains = validate(ROOT, self.record)
        self.assertAlmostEqual(gains["active"], 0.5)
        self.assertAlmostEqual(gains["smallExact"], 16.0)
        self.assertEqual(gains["smallCutoff"], 0.0)

    def test_scope_declares_the_nonzero_premise(self):
        self.record["formalScope"].pop("premise")
        with self.assertRaisesRegex(ValueError, "nonzero premise"):
            validate(ROOT, self.record)

    def test_proof_requires_resolvable_commit_and_declaration(self):
        for field, value in (("declaration", "Unknown.theorem"), ("sourceCommit", "f" * 40)):
            with self.subTest(field=field):
                altered = dict(self.record, proof={**self.record["proof"], field: value})
                with self.assertRaisesRegex(ValueError, "unresolved proof|proof-source pin does not resolve"):
                    validate(ROOT, altered)

    def test_unmeasured_study_has_no_invented_population(self):
        for field, value in (("applicability", "measured"), ("population", {"active": 100})):
            with self.subTest(field=field):
                altered = dict(self.record, studyHandoff={**self.record["studyHandoff"], field: value})
                with self.assertRaisesRegex(ValueError, "unmeasured applicability"):
                    validate(ROOT, altered)


class PublicReferenceTests(unittest.TestCase):
    def setUp(self):
        self.records = _load_records(ROOT)
        self.original = deepcopy(self.records)

    def test_real_inventory_resolves_offline(self):
        declarations, modules = validate_public_references(ROOT, self.records, self.original.values())
        self.assertIn("TheoremLibrary.Geometry.Sphere.erased_radius_future", declarations)
        self.assertIn("TheoremLibrary.Geometry.Sphere.normalization_singularValues", declarations)
        module = "TheoremLibrary.Geometry.Sphere.NormalizationSpectrum"
        self.assertIn(module, modules)
        self.assertEqual(declarations["TheoremLibrary.Geometry.Sphere.scaledTangentMap_rank"], module)

    def test_supporting_declarations_require_scope_and_share_the_source_pin(self):
        record = self.records["docs/applicability/frm-000003.json"]
        support = record["publicReference"]["supportingDeclarations"][0]
        scope = support.pop("applicability")
        with self.assertRaisesRegex(ValueError, "supporting declaration requires.*applicability"):
            validate_public_references(ROOT, self.records)
        support["applicability"] = scope
        support["sourcePath"] = "TheoremLibrary/Geometry/Sphere/Projection.lean"
        with self.assertRaisesRegex(ValueError, "missing or extra proof source pin"):
            validate_indexed_scope(ROOT, record)

    def test_foundational_records_are_present(self):
        foundational_ids = {f"FRM-{number:06d}" for number in range(1, 8)}
        self.assertTrue(foundational_ids <= {record["id"] for record in self.records.values()})
        self.records.pop("docs/applicability/frm-000004.json")
        with self.assertRaisesRegex(ValueError, "missing applicability records"):
            validate_public_references(ROOT, self.records)

    def test_null_research_checkpoint_cannot_hide_an_index_link(self):
        record = self.records["docs/applicability/frm-000001.json"]
        record["publicReference"]["researchNotes"] = None
        record["studyHandoff"]["checkpoint"] = None
        with self.assertRaisesRegex(ValueError, "unexpected Research Notes checkpoint for FRM-000001"):
            validate_public_references(ROOT, self.records)

    def test_extended_applicability_pins_and_handoff(self):
        for path, record in self.records.items():
            if Path(path) != RECORD:
                with self.subTest(path=path):
                    validate_indexed_scope(ROOT, record)

    def test_extended_applicability_rejects_missing_premise_or_source_pin(self):
        record = self.records["docs/applicability/frm-000023.json"]
        record["formalScope"]["premises"] = []
        with self.assertRaisesRegex(ValueError, "explicit proof premises"):
            validate_indexed_scope(ROOT, record)
        record = self.original["docs/applicability/frm-000023.json"]
        record["proofSource"]["sha256"].clear()
        with self.assertRaisesRegex(ValueError, "missing or extra proof source pin"):
            validate_indexed_scope(ROOT, record)

    def test_missing_source_and_duplicate_stable_identifier(self):
        path = "docs/applicability/frm-000133.json"
        record = self.records[path]
        record["proof"]["sourcePath"] = "TheoremLibrary/Missing.lean"
        with self.assertRaisesRegex(ValueError, "missing or mismatched declaration source"):
            validate_public_references(ROOT, self.records)
        self.records[path] = self.original[path]
        self.records["docs/applicability/duplicate.json"] = self.original[path]
        with self.assertRaisesRegex(ValueError, "duplicate or conflicting stable identifier"):
            validate_public_references(ROOT, self.records)

    def test_repointing_combined_alias_fails_against_reviewed_base(self):
        aliases = self.records["docs/applicability/frm-000023.json"]["publicReference"]["aliases"]
        aliases["LIB-SPH-005"] = aliases["LIB-SPH-001"]
        with self.assertRaisesRegex(ValueError, "silently removed or repointed: LIB-SPH-005"):
            validate_public_references(ROOT, self.records, self.original.values())

    def _workspace(self, temporary):
        root = Path(temporary)
        for path in ("TheoremLibrary.lean", "INDEX.md", "PUBLIC_CORE.md"):
            shutil.copyfile(ROOT / path, root / path)
        shutil.copytree(ROOT / "TheoremLibrary", root / "TheoremLibrary")
        return root

    def test_stale_public_inventory_and_removed_import(self):
        for path in ("PUBLIC_CORE.md", "TheoremLibrary.lean"):
            with self.subTest(path=path), tempfile.TemporaryDirectory() as temporary:
                root = self._workspace(temporary)
                file = root / path
                text = file.read_text(encoding="utf-8")
                kept = [line for line in text.splitlines() if "Sphere.RadialMemory" not in line]
                file.write_text("\n".join(kept) + "\n", encoding="utf-8")
                with self.assertRaisesRegex(ValueError, "module inventory differs from the public imports"):
                    validate_public_references(root, self.records)

    def test_module_rename_can_preserve_stable_names(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = self._workspace(temporary)
            original = Path("TheoremLibrary/Geometry/Sphere/RadialMemory.lean")
            renamed = original.with_name("ScaleQuotient.lean")
            (root / original).rename(root / renamed)
            for path in ("TheoremLibrary.lean", "INDEX.md", "PUBLIC_CORE.md"):
                file = root / path
                file.write_text(file.read_text(encoding="utf-8").replace("RadialMemory", "ScaleQuotient"),
                                encoding="utf-8")
            record = self.records["docs/applicability/frm-000023.json"]
            public = record["publicReference"]
            for reference in [record["proof"], *public["relatedDeclarations"], *public["supportingDeclarations"]]:
                reference["module"] = reference["module"].replace("RadialMemory", "ScaleQuotient")
                reference["sourcePath"] = renamed.as_posix()
            with (root / renamed).open("a", encoding="utf-8") as source:
                source.write("\nprivate theorem privateFixtureHelper : True := True.intro\n")
            validate_public_references(root, self.records, self.original.values())


if __name__ == "__main__":
    unittest.main()
