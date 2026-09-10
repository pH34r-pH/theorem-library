#!/usr/bin/env bash
set -euo pipefail

# Reuse the pinned toolchain and populated .lake tree; bootstrap once beforehand.
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
export LEAN_NUM_THREADS="${LEAN_NUM_THREADS:-1}"
if (($# == 0)); then
  set -- DomainScaling
fi
exec lake build "$@"
