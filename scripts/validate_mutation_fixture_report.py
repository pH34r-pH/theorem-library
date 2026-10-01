#!/usr/bin/env python3
"""Validate captured mutation coordinates against the embedded source."""

from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REPORT = ROOT / "reports" / "mutation-upstream-fixture.json"


def main() -> int:
    report = json.loads(REPORT.read_text(encoding="utf-8"))
    checked = 0
    for path, file_result in report["files"].items():
        source_lines = file_result["source"].splitlines()
        for mutant in file_result["mutants"]:
            location = mutant["location"]
            start = location["start"]
            end = location["end"]
            if start["line"] != end["line"]:
                raise SystemExit(f"{path}:{mutant['id']}: multiline ranges are not supported")
            line_number = start["line"]
            if not 1 <= line_number <= len(source_lines):
                raise SystemExit(f"{path}:{mutant['id']}: line is out of bounds")
            line = source_lines[line_number - 1]
            start_column = start["column"]
            end_column = end["column"]
            if not 1 <= start_column < end_column <= len(line) + 1:
                raise SystemExit(f"{path}:{mutant['id']}: columns are out of bounds")
            original = mutant.get("original")
            if not isinstance(original, str) or not original:
                raise SystemExit(f"{path}:{mutant['id']}: missing original token")
            actual = line[start_column - 1 : end_column - 1]
            if actual != original:
                raise SystemExit(
                    f"{path}:{mutant['id']}: range extracts {actual!r}, expected {original!r}"
                )
            checked += 1
    print(f"mutation report coordinates passed for {checked} mutant(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
