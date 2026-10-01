#!/usr/bin/env bash
set -euo pipefail

# Run the bounded Mutate.lean baseline and emit/verify a
# Mutation Testing Elements (Stryker) report.  The temporary source files are
# the only mutated artifacts; no project source is rewritten.

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
export LEAN_NUM_THREADS="${LEAN_NUM_THREADS:-1}"

mode=check
output="reports/mutation-baseline.json"
while (($# > 0)); do
  case "$1" in
    --check) mode=check ;;
    --write) mode=write ;;
    --output)
      shift
      (($# > 0)) || { echo "--output requires a path" >&2; exit 2; }
      output="$1"
      ;;
    *)
      echo "usage: $0 [--check|--write] [--output PATH]" >&2
      exit 2
      ;;
  esac
  shift
done

source_file=Mutate.lean
[[ -f "$source_file" ]] || { echo "missing $source_file" >&2; exit 1; }

temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

run_lean() {
  local source="$1"
  local log="$2"
  set +e
  lake env lean "$source" >"$log" 2>&1
  local status=$?
  set -e
  return "$status"
}

baseline_log="$temp_dir/baseline.log"
if ! run_lean "$source_file" "$baseline_log"; then
  cat "$baseline_log" >&2
  echo "Mutate.lean baseline failed" >&2
  exit 1
fi

make_variant() {
  local replacement="$1"
  local destination="$2"
  awk -v replacement="$replacement" '
    /-- MUTATION_TARGET$/ {
      print "  " replacement " -- MUTATION_TARGET"
      next
    }
    { print }
  ' "$source_file" >"$destination"
}

strip_strengthened_property() {
  local source="$1"
  local destination="$2"
  awk '
    /-- BEGIN STRENGTHENED PROPERTY/ { skip = 1; next }
    /-- END STRENGTHENED PROPERTY/ { skip = 0; next }
    !skip { print }
  ' "$source" >"$destination"
}

results="$temp_dir/results.tsv"
: >"$results"

run_mutant() {
  local id="$1"
  local mutator="$2"
  local replacement="$3"
  local classification="$4"
  local expected_baseline="$5"
  local expected_strengthened="$6"
  local reason="$7"
  local variant="$temp_dir/$id.lean"
  local baseline_variant="$temp_dir/$id-baseline.lean"
  local baseline_log="$temp_dir/$id-baseline.log"
  local strengthened_log="$temp_dir/$id-strengthened.log"

  make_variant "$replacement" "$variant"
  strip_strengthened_property "$variant" "$baseline_variant"

  if run_lean "$baseline_variant" "$baseline_log"; then
    baseline_status=0
  else
    baseline_status=1
  fi
  if run_lean "$variant" "$strengthened_log"; then
    strengthened_status=0
  else
    strengthened_status=1
  fi

  if [[ "$baseline_status" != "$expected_baseline" ||
        "$strengthened_status" != "$expected_strengthened" ]]; then
    echo "unexpected result for $id" >&2
    echo "expected baseline=$expected_baseline strengthened=$expected_strengthened" >&2
    echo "actual   baseline=$baseline_status strengthened=$strengthened_status" >&2
    cat "$baseline_log" >&2
    cat "$strengthened_log" >&2
    exit 1
  fi

  if [[ "$baseline_status" == 0 ]]; then
    status=Survived
  else
    status=Killed
  fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$id" "$mutator" "$status" "$classification" "$replacement" "$reason" >>"$results"
}

run_mutant \
  drop-radial-term \
  RemoveRadialTerm \
  'v i' \
  baseline-killed \
  1 1 \
  'The radial property rejects removal of the radial subtraction term.'

run_mutant \
  add-radial-term \
  AddRadialTerm \
  'v i + euclideanDot u v * u i' \
  baseline-killed \
  1 1 \
  'The radial property rejects changing subtraction to addition.'

run_mutant \
  use-input-vector \
  ReplaceRadialVector \
  'v i - euclideanDot u v * v i' \
  specification-gap \
  0 1 \
  'The radial and tangent properties survive, but mixed-direction additivity has a kernel-checked counterexample.'

run_mutant \
  add-zero-noise \
  AdditiveIdentity \
  'v i - euclideanDot u v * u i + 0' \
  equivalent-noise \
  0 0 \
  'The mutation is propositionally equivalent to the baseline and is retained as equivalent noise.'

line="$(grep -n -- '-- MUTATION_TARGET$' "$source_file" | cut -d: -f1)"
[[ "$line" =~ ^[0-9]+$ ]] || { echo "could not locate mutation target" >&2; exit 1; }

report="$temp_dir/report.json"
python3 - "$source_file" "$results" "$line" "$report" <<'PY'
import json
import sys
from pathlib import Path

source_path, results_path, line, report_path = sys.argv[1:]
source = Path(source_path).read_text(encoding="utf-8")
target_line = source.splitlines()[int(line) - 1]
target_start = target_line.index("v i") + 1
target_end = len(target_line) + 1
mutants = []
for raw in Path(results_path).read_text(encoding="utf-8").splitlines():
    mutant_id, mutator, status, classification, replacement, reason = raw.split("\t", 5)
    item = {
        "id": mutant_id,
        "mutatorName": mutator,
        "location": {
            "start": {"line": int(line), "column": target_start},
            "end": {"line": int(line), "column": target_end},
        },
        "status": status,
        "statusReason": f"classification={classification}; {reason}",
        "replacement": replacement,
        "coveredBy": ["radial-property", "tangent-property"],
        "testsCompleted": 2,
    }
    if status == "Killed":
        item["killedBy"] = ["radial-property"]
    mutants.append(item)

report = {
    "schemaVersion": "2",
    "config": {
        "target": "Mutate.lean:mutationTarget",
        "baselineProperties": ["radial-property", "tangent-property"],
        "strengthenedProperty": "mixed-additivity-property",
        "verifier": "Lean kernel via lake env lean",
    },
    "files": {
        "Mutate.lean": {
            "language": "lean",
            "source": source,
            "mutants": mutants,
        }
    },
    "testFiles": {
        "Mutate.lean": {
            "tests": [
                {"id": "radial-property", "name": "radial property"},
                {"id": "tangent-property", "name": "tangent property"},
                {"id": "mixed-additivity-property", "name": "mixed-direction additivity"},
            ]
        }
    },
    "thresholds": {"high": 100, "low": 0},
    "framework": {
        "name": "Theorem Library Mutate.lean baseline",
        "version": "0.1.0",
    },
}
Path(report_path).write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY

if [[ "$mode" == write ]]; then
  mkdir -p "$(dirname -- "$output")"
  cp "$report" "$output"
  echo "wrote $output"
else
  [[ -f "$output" ]] || { echo "missing $output; run with --write first" >&2; exit 1; }
  if ! cmp -s "$report" "$output"; then
    echo "$output is stale; run scripts/mutation_baseline.sh --write" >&2
    diff -u "$output" "$report" >&2 || true
    exit 1
  fi
  echo "mutation baseline and report are reproducible"
fi
