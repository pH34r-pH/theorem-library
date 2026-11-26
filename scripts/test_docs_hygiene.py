import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from docs_hygiene import changed_files, check_paths
from validate_applicability import RECORD, ROOT, validate


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


if __name__ == "__main__":
    unittest.main()
