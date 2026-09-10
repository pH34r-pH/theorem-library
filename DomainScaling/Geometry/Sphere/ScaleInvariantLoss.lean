import DomainScaling.Geometry.Sphere.Anisotropy
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Comp
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Tactic.Ring

/-! FRM-000021 / LIB-SPH-003: exact radial flatness, finite tangent-step norm
identity and derivative-at-zero angular scaling. -/
namespace DomainScaling.Geometry.Sphere
open scoped RealInnerProductSpace
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

private theorem normalization_differentiable (x : E) (hx : x ≠ 0) :
    DifferentiableAt ℝ (fun y : E => (1 / ‖y‖) • y) x := by
  have h := (hasFDerivAt_normalization_of_ne_zero x hx).differentiableAt
  change DifferentiableAt ℝ (fun y : E => ‖y‖⁻¹ • y) x at h
  simpa only [one_div] using h

/-- Composition through normalization has zero first-order radial sensitivity. -/
theorem scale_invariant_radial_flatness (ell : E → ℝ) (x : E) (hx : x ≠ 0)
    (hell : DifferentiableAt ℝ ell ((1 / ‖x‖) • x)) :
    fderiv ℝ (ell ∘ (fun y : E => (1 / ‖y‖) • y)) x x = 0 := by
  rw [fderiv_comp (f := fun y : E => (1 / ‖y‖) • y) x hell (normalization_differentiable x hx),
    ContinuousLinearMap.comp_apply, fderiv_normalization_apply_radial x hx, map_zero]

/-- A vector representing the composed differential is orthogonal to the state. -/
theorem scale_invariant_gradient_radial (ell : E → ℝ) (x grad : E) (hx : x ≠ 0)
    (hell : DifferentiableAt ℝ ell ((1 / ‖x‖) • x))
    (hgrad : ∀ v, fderiv ℝ (ell ∘ (fun y : E => (1 / ‖y‖) • y)) x v = ⟪grad, v⟫) :
    ⟪x, grad⟫ = 0 := by
  rw [real_inner_comm, ← hgrad x]
  exact scale_invariant_radial_flatness ell x hx hell

/-- Exact finite-step identity, valid for every real step size. -/
theorem tangent_step_norm_sq (x g : E) (eta : ℝ) (horth : ⟪x, g⟫ = 0) :
    ‖x - eta • g‖ ^ 2 = ‖x‖ ^ 2 + eta ^ 2 * ‖g‖ ^ 2 := by
  rw [norm_sub_sq_real, inner_smul_right, horth]
  simp [norm_smul, Real.norm_eq_abs, mul_pow, sq_abs]

/-- General chain-rule velocity: there is no extra inverse radius before DN_x. -/
theorem hasDerivAt_normalized_step (x g : E) (hx : x ≠ 0) :
    HasDerivAt (fun eta : ℝ => (1 / ‖x - eta • g‖) • (x - eta • g))
      (-(fderiv ℝ (fun y : E => (1 / ‖y‖) • y) x) g) 0 := by
  have hs : HasDerivAt (fun eta : ℝ => x - eta • g) (-g) 0 := by
    simpa using HasDerivAt.const_sub x ((hasDerivAt_id (0 : ℝ)).smul_const g)
  have hc := (normalization_differentiable x hx).hasFDerivAt.comp_hasDerivAt_of_eq
    (0 : ℝ) hs (by simp)
  simpa only [Function.comp_def, map_neg] using hc

/-- A fixed ambient tangent update gives inverse-radius angular velocity. -/
theorem hasDerivAt_normalized_tangent_step (x g : E) (hx : x ≠ 0)
    (horth : ⟪x, g⟫ = 0) :
    HasDerivAt (fun eta : ℝ => (1 / ‖x - eta • g‖) • (x - eta • g))
      (-(1 / ‖x‖) • g) 0 := by
  have h := hasDerivAt_normalized_step x g hx
  rw [fderiv_normalization_apply_tangent x g hx horth, ← neg_smul] at h
  exact h

/-- The additional inverse radius in the ambient update gives inverse-square velocity. -/
theorem hasDerivAt_normalized_scaled_tangent_step (x gu : E) (hx : x ≠ 0)
    (horth : ⟪x, gu⟫ = 0) :
    HasDerivAt (fun eta : ℝ =>
      (1 / ‖x - eta • ((1 / ‖x‖) • gu)‖) • (x - eta • ((1 / ‖x‖) • gu)))
      (-(1 / ‖x‖ ^ 2) • gu) 0 := by
  have ht : ⟪x, (1 / ‖x‖) • gu⟫ = 0 := by simp [inner_smul_right, horth]
  have h := hasDerivAt_normalized_tangent_step x ((1 / ‖x‖) • gu) hx ht
  have he : -(1 / ‖x‖) • ((1 / ‖x‖) • gu) = -(1 / ‖x‖ ^ 2) • gu := by
    rw [smul_smul]
    congr 1
    simp [one_div, pow_two]
  rw [he] at h
  exact h

/-- Exact rate norm for the explicitly radius-scaled tangent update. -/
theorem norm_angular_velocity_scaled (x gu : E) (hx : x ≠ 0)
    (horth : ⟪x, gu⟫ = 0) :
    ‖deriv (fun eta : ℝ =>
      (1 / ‖x - eta • ((1 / ‖x‖) • gu)‖) • (x - eta • ((1 / ‖x‖) • gu))) 0‖ =
      (1 / ‖x‖ ^ 2) * ‖gu‖ := by
  rw [(hasDerivAt_normalized_scaled_tangent_step x gu hx horth).deriv,
    norm_smul, Real.norm_eq_abs, abs_neg, abs_of_nonneg (one_div_nonneg.mpr (sq_nonneg ‖x‖))]

end DomainScaling.Geometry.Sphere
