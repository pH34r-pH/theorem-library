"""Bundle the exact proof inputs and compiled public modules from a checked build."""

from __future__ import annotations

import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile


ROOT = Path(__file__).resolve().parents[1]
FIXED_INPUTS = (
    "LICENSE", "NOTICE", "INDEX.md", "PUBLIC_CORE.md", "TheoremLibrary.lean",
    "lean-toolchain", "lakefile.lean", "lake-manifest.json",
)
PROOF_SCOPE = (
    *FIXED_INPUTS, "TheoremLibrary/", "docs/applicability/", "Mutate.lean",
    "reports/mutation-upstream-fixture.json", "scripts/", ".github/workflows/lean.yml",
)


def git(root: Path, *args: str) -> bytes:
    return subprocess.check_output(["git", *args], cwd=root)


def input_files(root: Path, sha: str) -> list[str]:
    entries = git(
        root, "ls-tree", "-r", "-z", sha, "--", *FIXED_INPUTS,
        "TheoremLibrary/", "docs/applicability/",
    )
    files = []
    for entry in entries.decode("utf-8").split("\0"):
        if not entry:
            continue
        metadata, filename = entry.split("\t", 1)
        if filename not in FIXED_INPUTS and not filename.endswith((".lean", ".json")):
            continue
        if not metadata.startswith(("100644 blob ", "100755 blob ")):
            raise ValueError(f"proof input must be a regular Git blob: {filename}")
        files.append(filename)
    if not set(FIXED_INPUTS) <= set(files):
        raise ValueError("missing required proof source inputs")
    return sorted(files)


def stage(root: Path, output: Path, sha: str, lean_version: str) -> None:
    if not re.fullmatch(r"[0-9a-f]{40}", sha) or git(root, "rev-parse", "HEAD").decode().strip() != sha:
        raise ValueError("proof candidate source must match the full checked-out revision")
    dirty = git(root, "status", "--porcelain", "--untracked-files=normal", "--", *PROOF_SCOPE)
    if dirty:
        raise ValueError(f"proof candidate requires clean proof source inputs:\n{dirty.decode().rstrip()}")
    filenames = input_files(root, sha)
    contents = {"source/" + name: git(root, "show", f"{sha}:{name}") for name in filenames}
    pin = contents["source/lean-toolchain"].decode().strip()
    version = pin.removeprefix("leanprover/lean4:v")
    if version == pin or f"version {version}," not in lean_version:
        raise ValueError("observed Lean version does not match the source pin")
    dependencies = json.loads(contents["source/lake-manifest.json"])
    mathlib = [package["rev"] for package in dependencies["packages"] if package["name"] == "mathlib"]
    if len(mathlib) != 1 or not re.fullmatch(r"[0-9a-f]{40}", mathlib[0]):
        raise ValueError("expected an exact Mathlib revision in the pinned Lake manifest")

    for name in filenames:
        if name != "TheoremLibrary.lean" and not (name.startswith("TheoremLibrary/") and name.endswith(".lean")):
            continue
        module = PurePosixPath(name).with_suffix(".olean")
        compiled = root / ".lake/build/lib/lean" / module
        if compiled.is_symlink() or not compiled.is_file() or compiled.stat().st_size == 0:
            raise ValueError(f"missing compiled proof module: {module}")
        contents[f"lib/lean/{module}"] = compiled.read_bytes()
        for suffix in (".private", ".server"):
            sidecar = compiled.with_name(compiled.name + suffix)
            if sidecar.is_file() and not sidecar.is_symlink():
                contents[f"lib/lean/{module}{suffix}"] = sidecar.read_bytes()

    receipt = {
        "schema_version": 1,
        "source_revision": sha,
        "lean_toolchain": pin,
        "lean_version": lean_version,
        "mathlib_revision": mathlib[0],
        "files_sha256": {name: hashlib.sha256(data).hexdigest() for name, data in sorted(contents.items())},
    }
    contents["proof-receipt.json"] = (json.dumps(receipt, indent=2) + "\n").encode()
    with output.open("xb") as raw, gzip.GzipFile(fileobj=raw, filename="", mode="wb", mtime=0) as gzip_file:
        with tarfile.open(fileobj=gzip_file, mode="w") as archive:
            for name, data in sorted(contents.items()):
                member = tarfile.TarInfo(name)
                member.size = len(data)
                archive.addfile(member, io.BytesIO(data))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-sha", required=True)
    parser.add_argument("--lean-version", required=True)
    parser.add_argument("--output", type=Path, required=True)
    arguments = parser.parse_args()
    try:
        stage(ROOT, arguments.output, arguments.source_sha, arguments.lean_version.strip())
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        parser.exit(1, f"Proof candidate rejected: {error}\n")


if __name__ == "__main__":
    main()
