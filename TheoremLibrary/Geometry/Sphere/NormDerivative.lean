import Mathlib.Analysis.InnerProductSpace.Calculus
import Mathlib.Analysis.SpecialFunctions.Sqrt

/-!
# Derivative of the norm away from zero

Ontology links:
- FRM-000003: checked unit-vector specialization
- FRM-000001: broader normalization-derivative target

This isolates the scalar-calculus step used by normalization.
-/

namespace TheoremLibrary.Geometry.Sphere

open scoped RealInnerProductSpace

/-- In a real inner-product space, away from zero the Fréchet derivative of the
norm at `x` is `(1 / ‖x‖) • innerSL ℝ x`. -/
theorem hasFDerivAt_norm_of_ne_zero
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (x : E) (hx : x ≠ 0) :
    HasFDerivAt (fun y : E => ‖y‖) ((1 / ‖x‖) • innerSL ℝ x) x := by
  have hsquare := (hasStrictFDerivAt_norm_sq x).hasFDerivAt
  have hnorm_ne : ‖x‖ ≠ 0 := norm_ne_zero_iff.mpr hx
  have hsq_ne : ‖x‖ ^ 2 ≠ 0 := pow_ne_zero 2 hnorm_ne
  have hsqrt := hsquare.sqrt hsq_ne
  convert hsqrt using 1
  · funext y
    exact (Real.sqrt_sq (norm_nonneg y)).symm
  · ext v
    simp [Real.sqrt_sq (norm_nonneg x), hnorm_ne]
    field_simp

/-- At a unit vector, the norm derivative simplifies to the inner-product
functional itself. -/
theorem hasFDerivAt_norm_of_norm_eq_one
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (u : E) (hunit : ‖u‖ = 1) :
    HasFDerivAt (fun x : E => ‖x‖) (innerSL ℝ u) u := by
  have hu : u ≠ 0 := by
    intro hzero
    simp [hzero] at hunit
  have h := hasFDerivAt_norm_of_ne_zero u hu
  simpa [hunit] using h

end TheoremLibrary.Geometry.Sphere
