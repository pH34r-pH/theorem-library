import TheoremLibrary.Geometry.Sphere.NormalizationSpectrum
import TheoremLibrary.Geometry.Sphere.ScaleInvariantLoss
import Mathlib.Analysis.Calculus.Gradient.Basic

/-! FRM-000149: actual Riesz gradient of a normalized loss, radial orthogonality,
finite-step norm identity and derivative-at-zero angular learning rate.
Completeness and differentiability are explicit; no optimizer is inferred from
an arbitrary covector and no generalization claim is made. -/

namespace TheoremLibrary.Geometry.Sphere
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

/-- Riesz gradient chain rule for an actual scale-invariant loss. The normalization
derivative is symmetric, so its adjoint is itself. -/
theorem hasGradientAt_normalized_loss (ell : E → ℝ) (x g : E) (hx : x ≠ 0)
    (hg : HasGradientAt ell g ((1 / ‖x‖) • x)) :
    HasGradientAt (fun z : E => ell ((1 / ‖z‖) • z))
      (fderiv ℝ (fun z : E => (1 / ‖z‖) • z) x g) x := by
  have hn := hasFDerivAt_normalization_of_ne_zero x hx
  change HasFDerivAt (fun z : E => ‖z‖⁻¹ • z) _ x at hn
  simp only [← one_div] at hn
  rw [hasGradientAt_iff_hasFDerivAt]
  have hc := hg.hasFDerivAt.comp x (f := fun z : E => (1 / ‖z‖) • z) hn
  have heq : InnerProductSpace.toDual ℝ E
      (fderiv ℝ (fun z : E => (1 / ‖z‖) • z) x g) =
      (InnerProductSpace.toDual ℝ E g).comp
        ((1 / ‖x‖) • (ContinuousLinearMap.id ℝ E -
          (innerSL ℝ ((1 / ‖x‖) • x)).smulRight ((1 / ‖x‖) • x))) := by
    ext v
    change inner ℝ (fderiv ℝ (fun z : E => (1 / ‖z‖) • z) x g) v =
      inner ℝ g (((1 / ‖x‖) • (ContinuousLinearMap.id ℝ E -
        (innerSL ℝ ((1 / ‖x‖) • x)).smulRight ((1 / ‖x‖) • x))) v)
    rw [fderiv_normalization_eq_scaled_tangent_projector x hx]
    exact scaledTangentMap_symmetric (1 / ‖x‖) ((1 / ‖x‖) • x) g v
  rw [heq]
  exact hc

theorem gradient_normalized_loss (ell : E → ℝ) (x : E) (hx : x ≠ 0)
    (hell : DifferentiableAt ℝ ell ((1 / ‖x‖) • x)) :
    gradient (fun z : E => ell ((1 / ‖z‖) • z)) x =
      (1 / ‖x‖) • (gradient ell ((1 / ‖x‖) • x) -
        inner ℝ ((1 / ‖x‖) • x) (gradient ell ((1 / ‖x‖) • x)) • ((1 / ‖x‖) • x)) := by
  rw [(hasGradientAt_normalized_loss ell x _ hx hell.hasGradientAt).gradient,
    fderiv_normalization_eq_scaled_tangent_projector x hx]
  rfl

theorem normalized_loss_gradient_orthogonal (ell : E → ℝ) (x : E) (hx : x ≠ 0)
    (hell : DifferentiableAt ℝ ell ((1 / ‖x‖) • x)) :
    inner ℝ x (gradient (fun z : E => ell ((1 / ‖z‖) • z)) x) = 0 := by
  rw [(hasGradientAt_normalized_loss ell x _ hx hell.hasGradientAt).gradient,
    fderiv_normalization_eq_scaled_tangent_projector x hx]
  have hu : ‖(1 / ‖x‖) • x‖ = 1 := by simp [norm_smul, hx]
  have h := scaledTangentMap_orthogonal (1 / ‖x‖) ((1 / ‖x‖) • x)
    (gradient ell ((1 / ‖x‖) • x)) hu
  rw [inner_smul_left] at h
  exact (mul_eq_zero.mp h).resolve_left (by simpa using one_div_ne_zero (norm_ne_zero_iff.mpr hx))

/-- The inverse-square angular velocity now follows for the actual Euclidean
gradient step; it is still a derivative at zero, not a finite-step angle identity. -/
theorem normalized_gradient_step_velocity (ell : E → ℝ) (x : E) (hx : x ≠ 0)
    (hell : DifferentiableAt ℝ ell ((1 / ‖x‖) • x)) :
    HasDerivAt (fun eta : ℝ =>
      (1 / ‖x - eta • gradient (fun z : E => ell ((1 / ‖z‖) • z)) x‖) •
        (x - eta • gradient (fun z : E => ell ((1 / ‖z‖) • z)) x))
      (-(1 / ‖x‖ ^ 2) • (gradient ell ((1 / ‖x‖) • x) -
        inner ℝ ((1 / ‖x‖) • x) (gradient ell ((1 / ‖x‖) • x)) • ((1 / ‖x‖) • x))) 0 := by
  have horth := normalized_loss_gradient_orthogonal ell x hx hell
  rw [gradient_normalized_loss ell x hx hell, inner_smul_right] at horth
  have hp := (mul_eq_zero.mp horth).resolve_left (one_div_ne_zero (norm_ne_zero_iff.mpr hx))
  simp only [gradient_normalized_loss ell x hx hell]
  exact hasDerivAt_normalized_scaled_tangent_step x _ hx hp

theorem normalized_gradient_step_norm_sq (ell : E → ℝ) (x : E) (hx : x ≠ 0)
    (hell : DifferentiableAt ℝ ell ((1 / ‖x‖) • x)) (eta : ℝ) :
    ‖x - eta • gradient (fun z : E => ell ((1 / ‖z‖) • z)) x‖ ^ 2 =
      ‖x‖ ^ 2 + eta ^ 2 * ‖gradient (fun z : E => ell ((1 / ‖z‖) • z)) x‖ ^ 2 :=
  tangent_step_norm_sq x _ eta (normalized_loss_gradient_orthogonal ell x hx hell)

end TheoremLibrary.Geometry.Sphere
