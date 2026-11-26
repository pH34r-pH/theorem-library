"""Offline failure injection for the existing Lean shell entrypoints."""

import os
import re
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PIN = (ROOT / "lean-toolchain").read_text(encoding="utf-8").strip().split(":v", 1)[1]
PRELUDE = """#!/bin/sh
record() {
  printf '%s|%s\n' "$1" "$PWD" >> "$FORMAL_TEST_TRACE"
  if [ "$FORMAL_TEST_FAILURE" = "$1" ]; then exit 73; fi
}
"""
LAKE = """
case "$*" in
  'env lean --version')
    record lean-version
    if [ "$FORMAL_TEST_FAILURE" = wrong-lean ]; then
      printf 'Lean (version 0.0, synthetic)\n'
    else
      printf 'Lean (version %s, synthetic)\n' "$FORMAL_TEST_LEAN"
    fi ;;
  'exe cache get '*) record cache ;;
  'build TheoremLibrary') record build ;;
  'build Alternate') record alternate ;;
  'env lean --root='*PublicReferences.lean) record public-lean ;;
  'env lean --root='*MissingReference.lean)
    record negative-lean
    printf 'Unknown identifier TheoremLibrary.Geometry.Sphere.missingPublicReferenceForValidation\n'
    exit 1 ;;
  'env leanchecker TheoremLibrary') record leanchecker ;;
  'env lean Mutate.lean') record mutation-lean ;;
  'build') record audit-build ;;
  'env '*'/axiom-audit '*) record axiom-audit ;;
  *) printf 'Unexpected fixture Lake command %s\n' "$*" >&2; exit 90 ;;
esac
"""
PYTHON = """
case "$1" in
  scripts/validate_applicability.py) record applicability ;;
  scripts/validate_public_references.py) record public-reference ;;
  scripts/validate_mutation_fixture_report.py) record mutation-report ;;
  *) printf 'Unexpected fixture Python command %s\n' "$*" >&2; exit 90 ;;
esac
"""
GIT = """
case "$*" in
  *'rev-parse HEAD')
    record audit-revision
    if [ "$FORMAL_TEST_FAILURE" = wrong-audit ]; then
      printf '0000000000000000000000000000000000000000\n'
    else
      printf '46024e005996495c65ef609368e11ab39c4222e3\n'
    fi ;;
  *'status --porcelain '*)
    record audit-status
    if [ "$FORMAL_TEST_FAILURE" = dirty-audit ]; then printf '?? local-audit.lean\n'; fi ;;
  *) printf 'Unexpected fixture Git command %s\n' "$*" >&2; exit 90 ;;
esac
"""
GREP = """
if [ "$1" = -nEw ]; then record placeholder; fi
exec "$FORMAL_TEST_NATIVE_GREP" "$@"
"""


@unittest.skipUnless(os.name == "posix", "formal script fixtures use POSIX Bash and tool stubs")
class ShellFailureTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        outside = Path(temporary.name)
        self.root = outside / "repository"
        (self.root / "scripts").mkdir(parents=True)
        self.tools = outside / "tools"
        self.tools.mkdir()
        self.trace = outside / "trace"
        self.bash = shutil.which("bash")
        self.native_grep = shutil.which("grep")
        self.assertIsNotNone(self.bash)
        self.assertIsNotNone(self.native_grep)
        for script in ("bootstrap_mathlib.sh", "dev_check.sh", "formal_common.sh", "validate_formal.sh"):
            shutil.copyfile(ROOT / "scripts" / script, self.root / "scripts" / script)
        shutil.copyfile(ROOT / "lean-toolchain", self.root / "lean-toolchain")
        for source in ("TheoremLibrary.lean", "Mutate.lean"):
            (self.root / source).write_text("-- synthetic source\n", encoding="utf-8")
        audit = self.root / ".lake/tools/axiom-audit"
        audit.mkdir(parents=True)
        shutil.copyfile(self.root / "lean-toolchain", audit / "lean-toolchain")
        for tool in ("cat", "cmp", "cp", "dirname", "mkdir", "mktemp", "rm", "rmdir"):
            binary = shutil.which(tool)
            self.assertIsNotNone(binary)
            (self.tools / tool).symlink_to(binary)
        for tool, stub in (("lake", LAKE), ("python", PYTHON), ("git", GIT), ("grep", GREP)):
            self._stub(tool, stub)

    def _stub(self, tool, body):
        path = self.tools / tool
        path.write_text(PRELUDE + body, encoding="utf-8")
        path.chmod(0o700)

    def _run(self, script, fault="", *args):
        self.trace.write_text("", encoding="utf-8")
        env = {
            **os.environ, "PATH": str(self.tools), "FORMAL_TEST_TRACE": str(self.trace),
            "FORMAL_TEST_FAILURE": fault, "FORMAL_TEST_LEAN": PIN,
            "FORMAL_TEST_NATIVE_GREP": self.native_grep,
        }
        return subprocess.run([self.bash, str(self.root / "scripts" / script), *args],
                              cwd=self.root.parent, env=env, capture_output=True, text=True, timeout=20)

    def _assert_failure(self, script, fault, diagnostic):
        result = self._run(script, fault)
        trace = self.trace.read_text(encoding="utf-8")
        self.assertNotEqual(0, result.returncode, result.stdout + result.stderr)
        self.assertIn(diagnostic, result.stderr)
        self.assertNotIn("axiom-audit|", trace)

    def test_missing_lake_and_unavailable_or_wrong_lean(self):
        self._assert_failure("dev_check.sh", "lean-version", "Pinned Lean prerequisite failed")
        self._assert_failure("dev_check.sh", "wrong-lean", "Pinned Lean prerequisite expected")
        (self.tools / "lake").unlink()
        self._assert_failure("dev_check.sh", "", "Formal prerequisite unavailable: lake")

    def test_bootstrap_and_development_accept_an_alternate_working_directory(self):
        bootstrap = self._run("bootstrap_mathlib.sh")
        self.assertEqual(0, bootstrap.returncode, bootstrap.stderr)
        self.assertIn(f"cache|{self.root}", self.trace.read_text(encoding="utf-8"))
        build = self._run("dev_check.sh", "", "Alternate")
        self.assertEqual(0, build.returncode, build.stderr)
        self.assertIn(f"alternate|{self.root}", self.trace.read_text(encoding="utf-8"))
        self._assert_failure("bootstrap_mathlib.sh", "cache", "Mathlib cache bootstrap failed")
        self._assert_failure("dev_check.sh", "build", "Lean development build failed")

    def test_each_formal_stage_failure_stops_the_validation(self):
        cases = {
            "build": "TheoremLibrary build failed",
            "public-lean": "Public reference elaboration failed",
            "leanchecker": "Independent leanchecker validation failed",
            "mutation-report": "Mutation fixture report validation failed",
            "mutation-lean": "Lean mutation specification fixture failed",
            "placeholder": "Placeholder source scan failed",
            "wrong-audit": "Unexpected axiom-audit revision",
            "dirty-audit": "Refusing a modified axiom-audit checkout",
            "audit-status": "Axiom-audit worktree inspection failed",
            "audit-build": "Axiom-audit build failed",
        }
        for fault, diagnostic in cases.items():
            with self.subTest(fault=fault):
                self._assert_failure("validate_formal.sh", fault, diagnostic)
        passing = self._run("validate_formal.sh")
        self.assertEqual(0, passing.returncode, passing.stdout + passing.stderr)
        self.assertIn("axiom-audit|", self.trace.read_text(encoding="utf-8"))


class BootstrapInventoryTests(unittest.TestCase):
    def test_bootstrap_covers_exact_direct_mathlib_imports(self):
        sources = [ROOT / "TheoremLibrary.lean", ROOT / "Mutate.lean", *(ROOT / "TheoremLibrary").rglob("*.lean")]
        imports = {
            name for source in sources for line in source.read_text(encoding="utf-8").splitlines()
            if line.startswith("import ") for name in line.split()[1:] if re.fullmatch(r"Mathlib(?:[.]\w+)+", name)
        }
        bootstrap = (ROOT / "scripts/bootstrap_mathlib.sh").read_text(encoding="utf-8")
        self.assertEqual(imports, set(re.findall(r"^\s+(Mathlib[.\w]+)", bootstrap, re.M)))


if __name__ == "__main__":
    unittest.main()
