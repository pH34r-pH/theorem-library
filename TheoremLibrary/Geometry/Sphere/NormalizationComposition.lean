import TheoremLibrary.Geometry.Sphere.NormalizationSpectrum

/-! FRM-000149: exact pre/post/sandwich derivative kernels, nonlinear chain rules,
arbitrary tangent gain, and a concrete affine-producer radial-survival boundary. -/

namespace TheoremLibrary.Geometry.Sphere

variable {E F G : Type*}
  [NormedAddCommGroup E] [InnerProductSpace ℝ E]
  [NormedAddCommGroup F] [InnerProductSpace ℝ F]
  [NormedAddCommGroup G] [NormedSpace ℝ G]

/-- The complete kernel after a producer is the inverse image of the output radial line. -/
theorem post_normalization_kernel (y : F) (hy : y ≠ 0) (J : E →L[ℝ] F) :
    ((fderiv ℝ (fun z : F => (1 / ‖z‖) • z) y).comp J).toLinearMap.ker =
      (ℝ ∙ y).comap J.toLinearMap := by
  rw [← normalization_derivative_ker y hy]
  rfl

theorem post_normalization_zero_iff (y : F) (hy : y ≠ 0)
    (J : E →L[ℝ] F) (v : E) :
    fderiv ℝ (fun z : F => (1 / ‖z‖) • z) y (J v) = 0 ↔ J v ∈ ℝ ∙ y := by
  change J v ∈ (fderiv ℝ (fun z : F => (1 / ‖z‖) • z) y).toLinearMap.ker ↔ _
  rw [normalization_derivative_ker y hy]

theorem pre_normalization_kills_radial (x : E) (hx : x ≠ 0)
    (J : E →L[ℝ] G) (a : ℝ) :
    J (fderiv ℝ (fun z : E => (1 / ‖z‖) • z) x (a • x)) = 0 := by
  rw [fderiv_normalization_radial_line x hx, map_zero]

/-- Even at unit radius the remaining tangent gain can be any real scalar. -/
theorem pre_normalization_arbitrary_tangent_gain (u v : E) (hu : ‖u‖ = 1)
    (hv : inner ℝ u v = 0) (c : ℝ) :
    ∃ J : E →L[ℝ] E,
      J (fderiv ℝ (fun z : E => (1 / ‖z‖) • z) u v) = c • v := by
  have hun : u ≠ 0 := by intro h; simp [h] at hu
  refine ⟨c • ContinuousLinearMap.id ℝ E, ?_⟩
  rw [fderiv_normalization_apply_tangent u v hun hv]
  simp [hu]

theorem normalization_sandwich_kills_radial (x : E) (hx : x ≠ 0)
    (y : F) (J : E →L[ℝ] F) (a : ℝ) :
    fderiv ℝ (fun z : F => (1 / ‖z‖) • z) y
      (J (fderiv ℝ (fun z : E => (1 / ‖z‖) • z) x (a • x))) = 0 := by
  rw [pre_normalization_kills_radial x hx, map_zero]

theorem post_normalization_tangent_image (y : F) (hy : y ≠ 0)
    (J : E →L[ℝ] F) (v : E) (hv : inner ℝ y (J v) = 0) :
    fderiv ℝ (fun z : F => (1 / ‖z‖) • z) y (J v) = (1 / ‖y‖) • J v :=
  fderiv_normalization_apply_tangent y (J v) hy hv

/-- Any nonzero tangent output can be produced from the original unit radial input.
Post-normalization therefore imposes no universal input-radial kernel. -/
theorem post_normalization_radial_survival (u : E) (hu : ‖u‖ = 1)
    (y v : F) (hy : y ≠ 0) (hv : inner ℝ y v = 0) (hne : v ≠ 0) :
    ∃ J : E →L[ℝ] F, J u = v ∧
      fderiv ℝ (fun z : F => (1 / ‖z‖) • z) y (J u) ≠ 0 := by
  refine ⟨(innerSL ℝ u).smulRight v, ?_, ?_⟩
  · simp [hu]
  · simp only [ContinuousLinearMap.smulRight_apply, innerSL_apply_apply]
    rw [real_inner_self_eq_norm_sq, hu]
    simp only [one_pow, one_smul]
    rw [fderiv_normalization_apply_tangent y v hy hv]
    exact smul_ne_zero (one_div_ne_zero (norm_ne_zero_iff.mpr hy)) hne

/-- Actual derivative of a post-normalized nonlinear producer, with differentiability explicit. -/
theorem fderiv_post_normalized (f : E → F) (x : E)
    (hf : DifferentiableAt ℝ f x) (hne : f x ≠ 0) :
    fderiv ℝ (fun z => (1 / ‖f z‖) • f z) x =
      (fderiv ℝ (fun z : F => (1 / ‖z‖) • z) (f x)).comp (fderiv ℝ f x) := by
  have hn : DifferentiableAt ℝ (fun z : F => (1 / ‖z‖) • z) (f x) := by
    have h := (hasFDerivAt_normalization_of_ne_zero (f x) hne).differentiableAt
    change DifferentiableAt ℝ (fun z : F => ‖z‖⁻¹ • z) (f x) at h
    simpa only [one_div] using h
  exact fderiv_comp x hn hf

theorem fderiv_post_normalized_zero_iff (f : E → F) (x v : E)
    (hf : DifferentiableAt ℝ f x) (hne : f x ≠ 0) :
    fderiv ℝ (fun z => (1 / ‖f z‖) • f z) x v = 0 ↔
      fderiv ℝ f x v ∈ ℝ ∙ f x := by
  rw [fderiv_post_normalized f x hf hne]
  exact post_normalization_zero_iff (f x) hne (fderiv ℝ f x) v

/-- Actual pre-normalized consumer: radial annihilation survives any differentiable consumer. -/
theorem fderiv_pre_normalized_radial (f : E → G) (x : E) (hx : x ≠ 0)
    (hf : DifferentiableAt ℝ f ((1 / ‖x‖) • x)) (a : ℝ) :
    fderiv ℝ (fun z : E => f ((1 / ‖z‖) • z)) x (a • x) = 0 := by
  have hn : DifferentiableAt ℝ (fun z : E => (1 / ‖z‖) • z) x := by
    have h := (hasFDerivAt_normalization_of_ne_zero x hx).differentiableAt
    change DifferentiableAt ℝ (fun z : E => ‖z‖⁻¹ • z) x at h
    simpa only [one_div] using h
  change fderiv ℝ (f ∘ (fun z : E => (1 / ‖z‖) • z)) x (a • x) = 0
  rw [fderiv_comp x (g := f) (f := fun z : E => (1 / ‖z‖) • z) hf hn]
  exact pre_normalization_kills_radial x hx (fderiv ℝ f ((1 / ‖x‖) • x)) a

/-- The survival witness is realized by an actual affine producer, not merely a
free Jacobian unrelated to the producer's output value. -/
theorem affine_producer_radial_survival (u : E) (hu : ‖u‖ = 1)
    (y v : F) (hy : y ≠ 0) (hv : inner ℝ y v = 0) (hne : v ≠ 0) :
    ∃ f : E → F, f u = y ∧ DifferentiableAt ℝ f u ∧
      fderiv ℝ (fun z => (1 / ‖f z‖) • f z) u u ≠ 0 := by
  obtain ⟨J, hJu, hsurvive⟩ := post_normalization_radial_survival u hu y v hy hv hne
  let f : E → F := fun z => y + (J z - J u)
  have hfu : f u = y := by simp [f]
  have hf : HasFDerivAt f J u := (J.hasFDerivAt.sub_const (J u)).const_add y
  refine ⟨f, hfu, hf.differentiableAt, ?_⟩
  rw [fderiv_post_normalized f u hf.differentiableAt (by simpa only [hfu] using hy)]
  rw [hf.fderiv, hfu]
  exact hsurvive

theorem two_dimensional_post_normalization_counterexample :
    ∃ (u : EuclideanSpace ℝ (Fin 2)) (f : EuclideanSpace ℝ (Fin 2) → EuclideanSpace ℝ (Fin 2)),
      ‖u‖ = 1 ∧ f u = u ∧ DifferentiableAt ℝ f u ∧
      fderiv ℝ (fun z => (1 / ‖f z‖) • f z) u u ≠ 0 := by
  let u : EuclideanSpace ℝ (Fin 2) := EuclideanSpace.single 0 1
  let v : EuclideanSpace ℝ (Fin 2) := EuclideanSpace.single 1 1
  have hu : ‖u‖ = 1 := by simp [u]
  have hv : ‖v‖ = 1 := by simp [v]
  have hun : u ≠ 0 := by intro h; simp [h] at hu
  have hvn : v ≠ 0 := by intro h; simp [h] at hv
  have huv : inner ℝ u v = 0 := by simp [u, v, EuclideanSpace.inner_single_left]
  obtain ⟨f, hfu, hf, hs⟩ := affine_producer_radial_survival u hu u v hun huv hvn
  exact ⟨u, f, hu, hfu, hf, hs⟩

end TheoremLibrary.Geometry.Sphere
