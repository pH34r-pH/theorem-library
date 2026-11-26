# Shared diagnostics for the repository's pinned formal commands.

require_formal_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Formal prerequisite unavailable: %s\n' "$1" >&2
    return 127
  fi
}

run_formal_stage() {
  local stage="$1"
  shift
  local status
  if "$@"; then
    return 0
  else
    status=$?
    printf '%s failed (%s exited %s)\n' "$stage" "$1" "$status" >&2
    return "$status"
  fi
}

require_pinned_lean() {
  require_formal_tool lake
  if [[ ! -r lean-toolchain ]]; then
    printf 'Formal prerequisite unavailable: lean-toolchain\n' >&2
    return 1
  fi
  local pin version
  pin=$(<lean-toolchain)
  version=$(run_formal_stage 'Pinned Lean prerequisite' lake env lean --version)
  if [[ "$pin" != leanprover/lean4:v* || "$version" != *"version ${pin#leanprover/lean4:v},"* ]]; then
    printf 'Pinned Lean prerequisite expected %s, observed %s\n' "$pin" "$version" >&2
    return 1
  fi
}
