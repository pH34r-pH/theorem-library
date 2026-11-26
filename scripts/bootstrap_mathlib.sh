#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
source scripts/formal_common.sh
require_pinned_lean

# Fetch the Mathlib imports of TheoremLibrary/ and Mutate.lean and their
# transitive cache dependencies. The offline tests check this direct list.
run_formal_stage 'Mathlib cache bootstrap' lake exe cache get \
  Mathlib.Algebra.BigOperators.Fin \
  Mathlib.Analysis.Calculus.Deriv.Add \
  Mathlib.Analysis.Calculus.Deriv.Comp \
  Mathlib.Analysis.Calculus.Deriv.Inv \
  Mathlib.Analysis.Calculus.Deriv.Mul \
  Mathlib.Analysis.Calculus.FDeriv.Mul \
  Mathlib.Analysis.Calculus.Gradient.Basic \
  Mathlib.Analysis.InnerProductSpace.Calculus \
  Mathlib.Analysis.InnerProductSpace.SingularValues \
  Mathlib.Analysis.SpecialFunctions.Sqrt \
  Mathlib.Data.Real.Basic \
  Mathlib.Logic.Function.Iterate \
  Mathlib.Tactic.FinCases \
  Mathlib.Tactic.Linarith \
  Mathlib.Tactic.NormNum \
  Mathlib.Tactic.Ring
