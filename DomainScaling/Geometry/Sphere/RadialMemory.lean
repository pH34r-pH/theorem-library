import DomainScaling.Geometry.Sphere.Anisotropy
import Mathlib.Logic.Function.Iterate

/-! Positive-scale orbit quotient and exact proposal-boundary radial memory loss.
FRM-000023, reserved by campaign #257; LIB-SPH-001/005.
An upstream proposal may encode previous radius into angle; that is not erased here. -/
namespace DomainScaling.Geometry.Sphere
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

noncomputable def normalizeState (x : E) : E := (1 / ‖x‖) • x

theorem normalizeState_positive_scale (x : E) (r : ℝ) (hr : 0 < r) :
    normalizeState (r • x) = normalizeState x := by
  simp [normalizeState, norm_smul, Real.norm_eq_abs, abs_of_pos hr, smul_smul,
    mul_inv_rev, one_div, inv_mul_cancel₀ (ne_of_gt hr), mul_assoc]

theorem normalizeState_norm (x : E) (hx : x ≠ 0) : ‖normalizeState x‖ = 1 := by
  simp [normalizeState, norm_smul, one_div, inv_mul_cancel₀ (norm_ne_zero_iff.mpr hx)]

theorem radius_times_normalize (x : E) (hx : x ≠ 0) :
    ‖x‖ • normalizeState x = x := by
  simp [normalizeState, smul_smul, one_div, mul_inv_cancel₀ (norm_ne_zero_iff.mpr hx)]

/-- Equal normalized nonzero states are exactly one positive-scale orbit. -/
theorem normalizeState_eq_iff_positive_scale (x y : E) (hx : x ≠ 0) (hy : y ≠ 0) :
    normalizeState x = normalizeState y ↔ ∃ r : ℝ, 0 < r ∧ y = r • x := by
  constructor
  · intro h
    refine ⟨‖y‖ / ‖x‖, div_pos (norm_pos_iff.mpr hy) (norm_pos_iff.mpr hx), ?_⟩
    calc
      y = ‖y‖ • normalizeState y := (radius_times_normalize y hy).symm
      _ = ‖y‖ • normalizeState x := by rw [h]
      _ = (‖y‖ / ‖x‖) • x := by simp [normalizeState, smul_smul, div_eq_mul_inv]
  · rintro ⟨r,hr,rfl⟩
    exact (normalizeState_positive_scale x r hr).symm

/-- Universal observational property on the nonzero domain. Values of g away
from the unit sphere are unconstrained, so no global uniqueness is asserted. -/
theorem positiveScaleInvariant_iff_normalizeFactors {O : Type*} (f : E → O) :
    (∀ x, x ≠ 0 → ∀ r : ℝ, 0 < r → f (r • x) = f x) ↔
      ∃ g : E → O, ∀ x, x ≠ 0 → f x = g (normalizeState x) := by
  constructor
  · intro h
    refine ⟨f, fun x hx => ?_⟩
    exact (h x hx (1 / ‖x‖) (one_div_pos.mpr (norm_pos_iff.mpr hx))).symm
  · rintro ⟨g,hg⟩ x hx r hr
    rw [hg x hx, hg (r • x) (smul_ne_zero (ne_of_gt hr) hx),
      normalizeState_positive_scale x r hr]

theorem normalizeFactor_unique_on_sphere {O : Type*} (f g h : E → O)
    (hg : ∀ x, x ≠ 0 → f x = g (normalizeState x))
    (hh : ∀ x, x ≠ 0 → f x = h (normalizeState x))
    (u : E) (hu : ‖u‖ = 1) : g u = h u := by
  have hne : u ≠ 0 := by intro he; simp [he] at hu
  have hn : normalizeState u = u := by simp [normalizeState, hu]
  simpa only [hn] using (hg u hne).symm.trans (hh u hne)

/-- Rescaling each proposal positively changes no normalized recurrence output. -/
theorem normalized_proposal_rescaling (F : E → E) (a : E → ℝ)
    (ha : ∀ x, 0 < a x) :
    (fun x => normalizeState (a x • F x)) = (fun x => normalizeState (F x)) := by
  funext x
  exact normalizeState_positive_scale (F x) (a x) (ha x)

theorem normalized_proposal_iterates (F : E → E) (a : E → ℝ)
    (ha : ∀ x, 0 < a x) (T : ℕ) (x : E) :
    (fun x => normalizeState (a x • F x))^[T] x =
      (fun x => normalizeState (F x))^[T] x := by
  rw [normalized_proposal_rescaling F a ha]

/-- After normalization erases proposal radius, every deterministic future agrees. -/
theorem erased_radius_future {O : Type*} (R : E → E) (obs : E → O)
    (x : E) (r : ℝ) (hr : 0 < r) (T : ℕ) :
    obs (R^[T] (normalizeState (r • x))) = obs (R^[T] (normalizeState x)) := by
  rw [normalizeState_positive_scale x r hr]

/-- No later linearized stage can recover the killed infinitesimal radial component. -/
theorem downstream_radial_annihilation (x : E) (hx : x ≠ 0) (a : ℝ)
    (A : E →L[ℝ] E) :
    A (fderiv ℝ (fun y : E => (1 / ‖y‖) • y) x (a • x)) = 0 := by
  rw [fderiv_normalization_radial_line x hx, map_zero]

end DomainScaling.Geometry.Sphere
