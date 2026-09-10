import TheoremLibrary.Geometry.Sphere.NormDerivative
import Mathlib.Analysis.Calculus.Deriv.Inv
import Mathlib.Analysis.Calculus.FDeriv.Mul

/-!
# Derivative of unit normalization

Ontology links:
- FRM-000001: broader nonzero normalization derivative target
- FRM-000004: reciprocal-norm derivative intermediate
- FRM-000005: unit-point normalization derivative
- FRM-000006: general radial annihilation by the normalization derivative
- FRM-000007: general tangent scaling by the normalization derivative

The calculus proof is separated from the continuous-linear-map normalization
identity so coercion/notation issues cannot obscure the differentiability result.
This module is an explicit formal-CI target: changes here must pass kernel build,
leanchecker, and axiom audit before any ontology status promotion.
-/

namespace TheoremLibrary.Geometry.Sphere

open scoped RealInnerProductSpace

/-- At a unit vector, the reciprocal norm has the derivative produced by composing
scalar inversion with the checked derivative of the norm. -/
theorem hasFDerivAt_inv_norm_of_norm_eq_one
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (u : E) (hunit : ‖u‖ = 1) :
    HasFDerivAt ((fun r : ℝ => r⁻¹) ∘ (fun x : E => ‖x‖))
      ((ContinuousLinearMap.toSpanSingleton ℝ (-1 : ℝ)).comp (innerSL ℝ u)) u := by
  have hnorm := hasFDerivAt_norm_of_norm_eq_one u hunit
  have hne : ‖u‖ ≠ 0 := by simp [hunit]
  have hinv := (hasFDerivAt_inv hne).comp u hnorm
  simpa [hunit] using hinv

/-- Native product-rule form of the derivative of unit normalization. -/
theorem hasFDerivAt_normalization_native_of_norm_eq_one
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (u : E) (hunit : ‖u‖ = 1) :
    HasFDerivAt
      (((fun r : ℝ => r⁻¹) ∘ (fun x : E => ‖x‖)) • (fun x : E => x))
      ((((fun r : ℝ => r⁻¹) ∘ (fun x : E => ‖x‖)) u) • ContinuousLinearMap.id ℝ E +
        ((ContinuousLinearMap.toSpanSingleton ℝ (-1 : ℝ)).comp (innerSL ℝ u)).smulRight u) u := by
  have hinv := hasFDerivAt_inv_norm_of_norm_eq_one u hunit
  have hid : HasFDerivAt (fun x : E => x) (ContinuousLinearMap.id ℝ E) u :=
    hasFDerivAt_id u
  exact hinv.smul hid

/-- The native product-rule derivative at a unit vector equals the tangent projector
`I - u uᵀ`. -/
theorem normalization_native_derivative_eq_tangent_projector
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (u : E) (hunit : ‖u‖ = 1) :
    (((fun r : ℝ => r⁻¹) ∘ (fun x : E => ‖x‖)) u) • ContinuousLinearMap.id ℝ E +
        ((ContinuousLinearMap.toSpanSingleton ℝ (-1 : ℝ)).comp (innerSL ℝ u)).smulRight u =
      ContinuousLinearMap.id ℝ E - (innerSL ℝ u).smulRight u := by
  apply ContinuousLinearMap.ext
  intro v
  simp [hunit, sub_eq_add_neg]

/-- At a unit vector, normalization has derivative `I - u uᵀ`. -/
theorem hasFDerivAt_normalization_of_norm_eq_one
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (u : E) (hunit : ‖u‖ = 1) :
    HasFDerivAt
      (((fun r : ℝ => r⁻¹) ∘ (fun x : E => ‖x‖)) • (fun x : E => x))
      (ContinuousLinearMap.id ℝ E - (innerSL ℝ u).smulRight u) u := by
  have hnative := hasFDerivAt_normalization_native_of_norm_eq_one u hunit
  rw [normalization_native_derivative_eq_tangent_projector u hunit] at hnative
  exact hnative

/-- Away from zero, reciprocal norm is differentiable with the native chain-rule map. -/
theorem hasFDerivAt_inv_norm_of_ne_zero
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (x : E) (hx : x ≠ 0) :
    HasFDerivAt ((fun r : ℝ => r⁻¹) ∘ (fun y : E => ‖y‖))
      ((ContinuousLinearMap.toSpanSingleton ℝ (-((‖x‖ ^ 2)⁻¹))).comp
        ((1 / ‖x‖) • innerSL ℝ x)) x := by
  have hnorm := hasFDerivAt_norm_of_ne_zero x hx
  have hne : ‖x‖ ≠ 0 := norm_ne_zero_iff.mpr hx
  exact (hasFDerivAt_inv hne).comp x hnorm

/-- Native product-rule form of the derivative of normalization away from zero. -/
theorem hasFDerivAt_normalization_native_of_ne_zero
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (x : E) (hx : x ≠ 0) :
    HasFDerivAt
      (((fun r : ℝ => r⁻¹) ∘ (fun y : E => ‖y‖)) • (fun y : E => y))
      ((((fun r : ℝ => r⁻¹) ∘ (fun y : E => ‖y‖)) x) • ContinuousLinearMap.id ℝ E +
        (((ContinuousLinearMap.toSpanSingleton ℝ (-((‖x‖ ^ 2)⁻¹))).comp
          ((1 / ‖x‖) • innerSL ℝ x)).smulRight x)) x := by
  have hinv := hasFDerivAt_inv_norm_of_ne_zero x hx
  have hid : HasFDerivAt (fun y : E => y) (ContinuousLinearMap.id ℝ E) x :=
    hasFDerivAt_id x
  exact hinv.smul hid

/-- The native derivative away from zero is the scaled tangent projector at the
normalized direction `u = ‖x‖⁻¹ • x`. -/
theorem normalization_native_derivative_eq_scaled_tangent_projector
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (x : E) (hx : x ≠ 0) :
    (((fun r : ℝ => r⁻¹) ∘ (fun y : E => ‖y‖)) x) • ContinuousLinearMap.id ℝ E +
        (((ContinuousLinearMap.toSpanSingleton ℝ (-((‖x‖ ^ 2)⁻¹))).comp
          ((1 / ‖x‖) • innerSL ℝ x)).smulRight x) =
      (1 / ‖x‖) •
        (ContinuousLinearMap.id ℝ E -
          (innerSL ℝ ((1 / ‖x‖) • x)).smulRight ((1 / ‖x‖) • x)) := by
  apply ContinuousLinearMap.ext
  intro v
  simp [sub_eq_add_neg]
  module

/-- For every nonzero `x`, normalization has derivative
`(1/‖x‖) (I - u uᵀ)` with `u = x/‖x‖`. -/
theorem hasFDerivAt_normalization_of_ne_zero
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (x : E) (hx : x ≠ 0) :
    HasFDerivAt
      (((fun r : ℝ => r⁻¹) ∘ (fun y : E => ‖y‖)) • (fun y : E => y))
      ((1 / ‖x‖) •
        (ContinuousLinearMap.id ℝ E -
          (innerSL ℝ ((1 / ‖x‖) • x)).smulRight ((1 / ‖x‖) • x))) x := by
  have hnative := hasFDerivAt_normalization_native_of_ne_zero x hx
  rw [normalization_native_derivative_eq_scaled_tangent_projector x hx] at hnative
  exact hnative

/-- At every nonzero state, the normalization derivative annihilates the radial
state direction itself. -/
theorem normalization_derivative_apply_radial
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (x : E) (hx : x ≠ 0) :
    ((1 / ‖x‖) •
      (ContinuousLinearMap.id ℝ E -
        (innerSL ℝ ((1 / ‖x‖) • x)).smulRight ((1 / ‖x‖) • x))) x = 0 := by
  have hne : ‖x‖ ≠ 0 := norm_ne_zero_iff.mpr hx
  have hcoef : ‖x‖⁻¹ * ‖x‖ ^ 2 * ‖x‖⁻¹ = 1 := by
    field_simp
  simp [real_inner_self_eq_norm_sq, hx, hne, smul_smul, hcoef]

/-- Tangent perturbations are preserved by normalization to first order, up to
its exact inverse-radius scale factor. -/
theorem normalization_derivative_apply_tangent
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (x v : E) (horth : ⟪x, v⟫ = 0) :
    ((1 / ‖x‖) •
      (ContinuousLinearMap.id ℝ E -
        (innerSL ℝ ((1 / ‖x‖) • x)).smulRight ((1 / ‖x‖) • x))) v =
      (1 / ‖x‖) • v := by
  simp [real_inner_smul_left, horth]

/-- Ontology: FRM-000006. For every nonzero state, the actual Fréchet derivative
of normalization annihilates the radial state direction. This specializes the
checked general derivative, rather than only identifying a linear map's action. -/
theorem fderiv_normalization_apply_radial
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (x : E) (hx : x ≠ 0) :
    (fderiv ℝ (fun y : E => (1 / ‖y‖) • y) x) x = 0 := by
  have hderiv := (hasFDerivAt_normalization_of_ne_zero x hx).fderiv
  change fderiv ℝ (fun y : E => ‖y‖⁻¹ • y) x = _ at hderiv
  simpa only [one_div, hderiv] using normalization_derivative_apply_radial x hx

/-- Ontology: FRM-000007. At a nonzero state, the actual Fréchet derivative of
normalization scales every orthogonal perturbation by exactly the inverse radius. -/
theorem fderiv_normalization_apply_tangent
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (x v : E) (hx : x ≠ 0) (horth : ⟪x, v⟫ = 0) :
    (fderiv ℝ (fun y : E => (1 / ‖y‖) • y) x) v = (1 / ‖x‖) • v := by
  have hderiv := (hasFDerivAt_normalization_of_ne_zero x hx).fderiv
  change fderiv ℝ (fun y : E => ‖y‖⁻¹ • y) x = _ at hderiv
  simpa only [one_div, hderiv] using normalization_derivative_apply_tangent x v horth

end TheoremLibrary.Geometry.Sphere
