import TheoremLibrary.Geometry.Sphere.Anisotropy
import Mathlib.Analysis.InnerProductSpace.SingularValues

/-! FRM-000133: the actual normalization derivative's kernel, rank and singular values. -/

namespace TheoremLibrary.Geometry.Sphere
open scoped RealInnerProductSpace
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

noncomputable def scaledTangentMap (c : ℝ) (u : E) : E →ₗ[ℝ] E :=
  (c • (ContinuousLinearMap.id ℝ E - (innerSL ℝ u).smulRight u)).toLinearMap

theorem scaledTangentMap_apply (c : ℝ) (u v : E) :
    scaledTangentMap c u v = c • (v-inner ℝ u v • u) := rfl

theorem scaledTangentMap_orthogonal (c : ℝ) (u v : E) (hu : ‖u‖=1) :
    inner ℝ u (scaledTangentMap c u v) = 0 := by
  simp [scaledTangentMap_apply,inner_smul_right,inner_sub_right,hu]

theorem scaledTangentMap_tangent (c : ℝ) (u v : E) (hv : inner ℝ u v=0) :
    scaledTangentMap c u v = c • v := by simp [scaledTangentMap_apply,hv]

theorem scaledTangentMap_symmetric (c : ℝ) (u : E) : (scaledTangentMap c u).IsSymmetric := by
  intro v w
  simp only [scaledTangentMap_apply,inner_smul_left,inner_smul_right,
    inner_sub_left,inner_sub_right,conj_trivial]
  rw [real_inner_comm v u]
  ring

theorem scaledTangentMap_ker (c : ℝ) (hc : c ≠ 0) (u : E) (hu : ‖u‖=1) :
    (scaledTangentMap c u).ker = ℝ ∙ u := by
  ext v
  rw [LinearMap.mem_ker,scaledTangentMap_apply,smul_eq_zero]
  simp only [hc,false_or,sub_eq_zero,Submodule.mem_span_singleton]
  constructor
  · intro h
    exact ⟨inner ℝ u v,h.symm⟩
  · rintro ⟨a,rfl⟩
    simp [inner_smul_right,hu]

variable [FiniteDimensional ℝ E]

theorem scaledTangentMap_rank (c : ℝ) (hc : c ≠ 0) (u : E) (hu : ‖u‖=1) :
    Module.finrank ℝ (scaledTangentMap c u).range + 1 = Module.finrank ℝ E := by
  have hn : u ≠ 0 := by intro h; simp [h] at hu
  have h := (scaledTangentMap c u).finrank_range_add_finrank_ker
  rw [scaledTangentMap_ker c hc u hu,finrank_span_singleton hn] at h
  exact h

theorem scaledTangentMap_singularValues (c : ℝ) (hc : 0<c) (u : E) (hu : ‖u‖=1) (i : ℕ) :
    (scaledTangentMap c u).singularValues i =
      if i < Module.finrank ℝ E-1 then c else 0 := by
  have hr := scaledTangentMap_rank c hc.ne' u hu
  have hrank : Module.finrank ℝ (scaledTangentMap c u).range = Module.finrank ℝ E-1 := by omega
  by_cases hi : i < Module.finrank ℝ E-1
  · rw [ite_eq_left hi]
    have hpos : 0 < (scaledTangentMap c u).singularValues i := by
      rw [LinearMap.singularValues_pos_iff_lt_finrank_range,hrank]
      exact hi
    have hidim : i < Module.finrank ℝ E := by omega
    obtain ⟨v,hv⟩ := ((scaledTangentMap c u).hasEigenvalue_adjoint_comp_self_sq_singularValues hidim).exists_hasEigenvector
    have heq := hv.apply_eq_smul
    rw [(scaledTangentMap_symmetric c u).adjoint_eq] at heq
    change scaledTangentMap c u (scaledTangentMap c u v) =
      ((scaledTangentMap c u).singularValues i)^2 • v at heq
    have hinner := congrArg (fun v => inner ℝ u v) heq
    rw [scaledTangentMap_orthogonal c u _ hu,inner_smul_right] at hinner
    have huv : inner ℝ u v=0 :=
      (mul_eq_zero.mp hinner.symm).resolve_left (pow_ne_zero 2 hpos.ne')
    rw [scaledTangentMap_tangent c u v huv,map_smul,scaledTangentMap_tangent c u v huv,
      smul_smul] at heq
    have hs := (smul_left_injective ℝ hv.2) heq
    nlinarith
  · rw [ite_eq_right hi]
    exact ((scaledTangentMap c u).singularValues_eq_zero_iff_le_finrank_range).mpr (by omega)

theorem normalization_singularValues (x : E) (hx : x ≠ 0) (i : ℕ) :
    (fderiv ℝ (fun y : E => (1/‖y‖) • y) x).toLinearMap.singularValues i =
      if i < Module.finrank ℝ E-1 then 1/‖x‖ else 0 := by
  have hc : 0 < 1/‖x‖ := one_div_pos.mpr (norm_pos_iff.mpr hx)
  have hu : ‖(1/‖x‖) • x‖ = 1 := by simp [norm_smul,hx]
  rw [fderiv_normalization_eq_scaled_tangent_projector x hx]
  exact scaledTangentMap_singularValues (1/‖x‖) hc ((1/‖x‖) • x) hu i

omit [FiniteDimensional ℝ E] in
theorem normalization_derivative_ker (x : E) (hx : x ≠ 0) :
    (fderiv ℝ (fun y : E => (1/‖y‖) • y) x).toLinearMap.ker = ℝ ∙ x := by
  have hc : 0 < 1/‖x‖ := one_div_pos.mpr (norm_pos_iff.mpr hx)
  have hu : ‖(1/‖x‖) • x‖ = 1 := by simp [norm_smul,hx]
  rw [fderiv_normalization_eq_scaled_tangent_projector x hx]
  change (scaledTangentMap (1/‖x‖) ((1/‖x‖) • x)).ker = _
  rw [scaledTangentMap_ker _ hc.ne' _ hu,Submodule.span_singleton_smul_eq (isUnit_iff_ne_zero.mpr hc.ne')]

theorem normalization_derivative_range (x : E) (hx : x ≠ 0) :
    (fderiv ℝ (fun y : E => (1/‖y‖) • y) x).toLinearMap.range = (ℝ ∙ x)ᗮ := by
  have hs : (fderiv ℝ (fun y : E => (1/‖y‖) • y) x).toLinearMap.IsSymmetric := by
    rw [fderiv_normalization_eq_scaled_tangent_projector x hx]
    exact scaledTangentMap_symmetric _ _
  have h := LinearMap.orthogonal_ker (fderiv ℝ (fun y : E => (1/‖y‖) • y) x).toLinearMap
  rw [normalization_derivative_ker x hx,hs.adjoint_eq] at h
  exact h.symm

theorem normalization_derivative_rank (x : E) (hx : x ≠ 0) :
    Module.finrank ℝ (fderiv ℝ (fun y : E => (1/‖y‖) • y) x).toLinearMap.range + 1 =
      Module.finrank ℝ E := by
  have h := (fderiv ℝ (fun y : E => (1/‖y‖) • y) x).toLinearMap.finrank_range_add_finrank_ker
  rw [normalization_derivative_ker x hx,finrank_span_singleton hx] at h
  exact h

end TheoremLibrary.Geometry.Sphere
