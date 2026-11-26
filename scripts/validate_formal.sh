#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
export LEAN_NUM_THREADS=1

python scripts/validate_applicability.py
lake build TheoremLibrary

check_public_reference_resolution() (
    local temp
    temp=$(mktemp -d)
    trap 'rm -f -- "$temp/PublicReferences.lean" "$temp/MissingReference.lean" "$temp/negative.log"; rmdir -- "$temp"' EXIT
    python scripts/validate_public_references.py --base "${THEOREM_REFERENCE_BASE:-}" \
      --lean-output "$temp/PublicReferences.lean"
    lake env lean --root="$temp" "$temp/PublicReferences.lean"
    printf '%s\n' 'import TheoremLibrary' \
      '#check TheoremLibrary.Geometry.Sphere.missingPublicReferenceForValidation' > "$temp/MissingReference.lean"
    if lake env lean --root="$temp" "$temp/MissingReference.lean" > "$temp/negative.log" 2>&1; then
        echo 'Public reference check accepted a missing Lean declaration.' >&2
        exit 1
    fi
    if ! grep -E 'Unknown (identifier|constant).*missingPublicReferenceForValidation' "$temp/negative.log"; then
        cat "$temp/negative.log" >&2
        echo 'Missing public declaration fixture failed for an unexpected reason.' >&2
        exit 1
    fi
)
check_public_reference_resolution

lake env leanchecker TheoremLibrary
python scripts/validate_mutation_fixture_report.py
lake env lean Mutate.lean

# Scan project Lean sources, including untracked files, but not dependencies.
# Deliberately reject placeholder words even in comments. grep errors fail closed.
shopt -s globstar nullglob
sources=(Mutate.lean TheoremLibrary.lean TheoremLibrary/**/*.lean)
if grep -nEw 'sorry|admit' "${sources[@]}"; then
  echo 'Placeholder audit failed: remove sorry/admit from project Lean sources.' >&2
  exit 1
else
  status=$?
  if ((status != 1)); then exit "$status"; fi
fi
echo 'Placeholder audit passed.'

# Same tool revision and permitted axioms as lean-action@v1's audit.
# Retain the tool build under .lake for subsequent local validation runs.
audit_ref=v0.1.2
audit_sha=46024e005996495c65ef609368e11ab39c4222e3
audit_dir="$PWD/.lake/tools/axiom-audit"
if [[ ! -d "$audit_dir" ]]; then
  mkdir -p "$(dirname "$audit_dir")"
  git clone --depth 1 --branch "$audit_ref" \
    https://github.com/leanprover-community/axiom-audit.git "$audit_dir"
fi
if [[ "$(git -C "$audit_dir" rev-parse HEAD)" != "$audit_sha" ]]; then
  echo "Unexpected axiom-audit revision; expected $audit_sha" >&2
  exit 1
fi
if [[ -n "$(git -C "$audit_dir" status --porcelain --untracked-files=no -- . ':!lean-toolchain')" ]]; then
  echo 'Refusing a modified axiom-audit checkout.' >&2
  exit 1
fi
if ! cmp -s lean-toolchain "$audit_dir/lean-toolchain"; then
  cp lean-toolchain "$audit_dir/lean-toolchain"
fi
(cd "$audit_dir" && lake build)
lake env "$audit_dir/.lake/build/bin/axiom-audit" \
  --root TheoremLibrary --allow propext,Classical.choice,Quot.sound
