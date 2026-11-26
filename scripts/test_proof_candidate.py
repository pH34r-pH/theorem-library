import hashlib
import json
from pathlib import Path
import subprocess
import tarfile
import tempfile
import unittest

from stage_proof_candidate import FIXED_INPUTS, stage


class ProofCandidateTest(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name)
        self.root = self.directory / "checkout"
        self.root.mkdir()
        self.git("init", "-q")
        for name in FIXED_INPUTS:
            (self.root / name).write_bytes(b"fixture\n")
        (self.root / "lean-toolchain").write_text("leanprover/lean4:v4.34.0-rc2\n", encoding="utf-8")
        (self.root / "lake-manifest.json").write_text(json.dumps({
            "packages": [{"name": "mathlib", "rev": "a" * 40}],
        }), encoding="utf-8")
        (self.root / ".gitignore").write_text("/.lake/\n", encoding="utf-8")
        proofs = self.root / "TheoremLibrary"
        proofs.mkdir()
        (proofs / "Sample.lean").write_bytes(b"sample fixture source\n")
        self.git("add", ".")
        self.git("-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid",
                 "commit", "-q", "--no-gpg-sign", "-m", "Pinned synthetic proof inputs")
        self.sha = self.git("rev-parse", "HEAD").strip()
        self.lean = "Lean (version 4.34.0-rc2, test fixture)"
        compiled = self.root / ".lake/build/lib/lean"
        (compiled / "TheoremLibrary").mkdir(parents=True)
        (compiled / "TheoremLibrary.olean").write_bytes(b"public root fixture")
        self.sample = compiled / "TheoremLibrary/Sample.olean"
        self.sample.write_bytes(b"public theorem fixture")
        self.sample.with_name("Sample.olean.private").write_bytes(b"proof sidecar fixture")
        (compiled / "Unrelated.olean").write_bytes(b"unrelated fixture")

    def git(self, *args):
        return subprocess.check_output(["git", *args], cwd=self.root, text=True)

    def test_byte_identical_bundle_and_receipt(self):
        first = self.directory / "first.tar.gz"
        second = self.directory / "second.tar.gz"
        stage(self.root, first, self.sha, self.lean)
        stage(self.root, second, self.sha, self.lean)
        self.assertEqual(first.read_bytes(), second.read_bytes())
        with tarfile.open(first) as archive:
            receipt = json.load(archive.extractfile("proof-receipt.json"))
            self.assertEqual(receipt["source_revision"], self.sha)
            self.assertEqual(receipt["mathlib_revision"], "a" * 40)
            self.assertIn("lib/lean/TheoremLibrary/Sample.olean.private", receipt["files_sha256"])
            self.assertNotIn("lib/lean/Unrelated.olean", archive.getnames())
            self.assertEqual(set(archive.getnames()), {"proof-receipt.json", *receipt["files_sha256"]})
            for name, digest in receipt["files_sha256"].items():
                self.assertEqual(hashlib.sha256(archive.extractfile(name).read()).hexdigest(), digest)

    def test_wrong_revision_toolchain_and_dirty_checkout_are_rejected(self):
        output = self.directory / "output.tar.gz"
        with self.assertRaisesRegex(ValueError, "checked-out revision"):
            stage(self.root, output, "b" * 40, self.lean)
        with self.assertRaisesRegex(ValueError, "Lean version"):
            stage(self.root, output, self.sha, "Lean (version 4.35.0, fixture)")
        (self.root / "TheoremLibrary/Sample.lean").write_bytes(b"changed")
        with self.assertRaisesRegex(ValueError, "clean proof source"):
            stage(self.root, output, self.sha, self.lean)
        self.assertFalse(output.exists())

    def test_unrelated_workflow_download_is_excluded(self):
        (self.root / "runner-tool").write_bytes(b"installed CI utility")
        output = self.directory / "output.tar.gz"
        stage(self.root, output, self.sha, self.lean)
        with tarfile.open(output) as archive:
            self.assertFalse(any(name.endswith("runner-tool") for name in archive.getnames()))

    def test_missing_compiled_module_fails_before_creating_bundle(self):
        output = self.directory / "output.tar.gz"
        self.sample.unlink()
        with self.assertRaisesRegex(ValueError, "missing compiled proof module"):
            stage(self.root, output, self.sha, self.lean)
        self.assertFalse(output.exists())


if __name__ == "__main__":
    unittest.main()
