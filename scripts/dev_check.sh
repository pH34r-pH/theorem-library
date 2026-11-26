#!/usr/bin/env bash
set -euo pipefail

# Reuse the pinned toolchain and populated .lake tree; bootstrap once beforehand.
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
source scripts/formal_common.sh
require_pinned_lean
export LEAN_NUM_THREADS="${LEAN_NUM_THREADS:-1}"
if (($# == 0)); then
  set -- TheoremLibrary
fi
run_formal_stage 'Lean development build' lake build "$@"
