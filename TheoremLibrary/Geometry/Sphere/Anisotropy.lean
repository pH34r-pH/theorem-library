import TheoremLibrary.Geometry.Sphere.Normalization
import Mathlib.Tactic.Linarith

/-!
# Radial and tangent behavior of normalization

This module characterizes the first-order anisotropy of vector normalization.
For a nonzero state `x`, the derivative of `x ↦ x / ‖x‖` annihilates the
radial direction and scales tangent directions by `1 / ‖x‖`. At unit radius,
tangent perturbations are therefore preserved to first order.

The result is local and geometric. It does not assign semantic meaning to
radial or tangent directions, and it does not determine the behavior of a
multi-step nonlinear recurrence.

Stable references: LIB-SPH-002 / FRM-000020.
-/

namespace TheoremLibrary.Geometry.Sphere
open scoped RealInnerProductSpace

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- Exact derivative identification from the existing nonzero HasFDerivAt theorem. -/
theorem fderiv_normalization_eq_scaled_tangent_projector (x : E) (hx : x ≠ 0) :
    fderiv ℝ (fun y : E => (1 / ‖y‖) • y) x =
      (1 / ‖x‖) • (ContinuousLinearMap.id ℝ E -
        (innerSL ℝ ((1 / ‖x‖) • x)).smulRight ((1 / ‖x‖) • x)) := by
  have h := (hasFDerivAt_normalization_of_ne_zero x hx).fderiv
  change fderiv ℝ (fun y : E => ‖y‖⁻¹ • y) x = _ at h
  simpa only [one_div] using h

/-- The entire radial line is in the derivative's kernel. -/
theorem fderiv_normalization_radial_line (x : E) (hx : x ≠ 0) (a : ℝ) :
    fderiv ℝ (fun y : E => (1 / ‖y‖) • y) x (a • x) = 0 := by
  rw [map_smul, fderiv_normalization_apply_radial x hx, smul_zero]

/-- Tangent gain is exactly inverse radius in norm, not just bounded by it. -/
theorem norm_fderiv_normalization_tangent (x v : E) (hx : x ≠ 0)
    (horth : ⟪x, v⟫ = 0) :
    ‖fderiv ℝ (fun y : E => (1 / ‖y‖) • y) x v‖ = (1 / ‖x‖) * ‖v‖ := by
  rw [fderiv_normalization_apply_tangent x v hx horth, norm_smul,
    Real.norm_eq_abs, abs_of_nonneg (one_div_nonneg.mpr (norm_nonneg x))]

/-- Unit-radius tangent vectors are fixed to first order. -/
theorem fderiv_normalization_tangent_of_norm_eq_one (x v : E)
    (hunit : ‖x‖ = 1) (horth : ⟪x, v⟫ = 0) :
    fderiv ℝ (fun y : E => (1 / ‖y‖) • y) x v = v := by
  have hx : x ≠ 0 := by intro h; simp [h] at hunit
  rw [fderiv_normalization_apply_tangent x v hx horth, hunit]
  simp

/-- With a nonzero tangent witness the two channels have strictly separated action. -/
theorem normalization_derivative_gain_separation (x v : E) (hx : x ≠ 0)
    (hv : v ≠ 0) (horth : ⟪x, v⟫ = 0) :
    ‖fderiv ℝ (fun y : E => (1 / ‖y‖) • y) x x‖ = 0 ∧
    0 < ‖fderiv ℝ (fun y : E => (1 / ‖y‖) • y) x v‖ := by
  constructor
  · rw [fderiv_normalization_apply_radial x hx, norm_zero]
  · rw [norm_fderiv_normalization_tangent x v hx horth]
    exact mul_pos (one_div_pos.mpr (norm_pos_iff.mpr hx)) (norm_pos_iff.mpr hv)

/-- Normalization's derivative cannot have a common norm gain on both nonzero channels. -/
theorem normalization_derivative_no_common_gain (x v : E) (hx : x ≠ 0)
    (hv : v ≠ 0) (horth : ⟪x, v⟫ = 0) :
    ¬ ∃ g : ℝ, ∀ w : E,
      ‖fderiv ℝ (fun y : E => (1 / ‖y‖) • y) x w‖ = g * ‖w‖ := by
  rintro ⟨g, hg⟩
  obtain ⟨hrad, htan⟩ := normalization_derivative_gain_separation x v hx hv horth
  have hxpos := norm_pos_iff.mpr hx
  have hgx := hg x
  have hgv := hg v
  have hg0 : g = 0 := by nlinarith
  rw [hg0, zero_mul] at hgv
  linarith

end TheoremLibrary.Geometry.Sphere
