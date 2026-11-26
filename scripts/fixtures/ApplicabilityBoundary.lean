import TheoremLibrary.Geometry.Sphere.NormalizationSpectrum
import TheoremLibrary.Geometry.Sphere.Projection
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.NormNum

/-!
Kernel-checked counterexamples for the assumptions in FRM-000002 and
LIB-SPH-002 / FRM-000020. These examples exercise the public definitions
and lemmas on exact real vectors.
-/

open TheoremLibrary.Geometry.Sphere
open scoped RealInnerProductSpace

private def nonunit : Fin 2 → ℝ := fun i => if i = 0 then 2 else 0

-- A nonzero radial direction is insufficient without the unit premise.
example : nonunit ≠ 0 ∧ tangentProject nonunit nonunit ≠ 0 := by
  constructor
  · intro h
    have first := congrFun h (0 : Fin 2)
    norm_num [nonunit] at first
  · intro h
    have first := congrFun h (0 : Fin 2)
    norm_num [nonunit, tangentProject, euclideanDot] at first

private abbrev Plane := EuclideanSpace ℝ (Fin 2)
private noncomputable def radial : Plane := EuclideanSpace.single 0 1
private noncomputable def tangent : Plane := EuclideanSpace.single 1 1

-- Exact normalization at radius two scales a unit tangent instead of fixing it.
example :
    fderiv ℝ (fun z : Plane => (1 / ‖z‖) • z) ((2 : ℝ) • radial) tangent ≠ tangent := by
  have hr : ‖radial‖ = 1 := by simp [radial]
  have ht : ‖tangent‖ = 1 := by simp [tangent]
  have radius : ‖(2 : ℝ) • radial‖ = 2 := by norm_num [norm_smul, hr]
  have nonzero : (2 : ℝ) • radial ≠ 0 := by
    intro h
    rw [h, norm_zero] at radius
    norm_num at radius
  have orthogonal : inner ℝ ((2 : ℝ) • radial) tangent = 0 := by
    simp [radial, tangent, inner_smul_left, EuclideanSpace.inner_single_left]
  rw [fderiv_normalization_apply_tangent _ _ nonzero orthogonal, radius]
  intro h
  have equalNorm := congrArg (fun x : Plane => ‖x‖) h
  norm_num [norm_smul, ht] at equalNorm
