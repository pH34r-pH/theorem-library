import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Data.Real.Basic

/-!
# Tangent projection on the unit sphere

This module establishes the elementary projection identities used by the later
normalization results. For a unit direction `u`, the tangent projector removes
the radial component parallel to `u` and fixes vectors orthogonal to `u`.

These are algebraic projection facts; identifying this projector with the
Fréchet derivative of normalization is proved separately in `Normalization.lean`.

Stable reference: FRM-000002.
-/

namespace TheoremLibrary.Geometry.Sphere

open scoped BigOperators

/-- Finite-dimensional Euclidean dot product. -/
def euclideanDot {n : ℕ} (u v : Fin n → ℝ) : ℝ :=
  ∑ i, u i * v i

/-- The Euclidean tangent-space projector `v ↦ v - ⟪u,v⟫u`. -/
def tangentProject {n : ℕ} (u v : Fin n → ℝ) : Fin n → ℝ :=
  fun i => v i - euclideanDot u v * u i

/-- For a unit vector, the tangent projector annihilates its radial direction. -/
theorem tangentProject_radial {n : ℕ} (u : Fin n → ℝ)
    (hunit : euclideanDot u u = 1) :
    tangentProject u u = 0 := by
  funext i
  simp [tangentProject, hunit]

/-- A vector orthogonal to `u` is fixed by the tangent projector. -/
theorem tangentProject_tangent {n : ℕ} (u v : Fin n → ℝ)
    (horth : euclideanDot u v = 0) :
    tangentProject u v = v := by
  funext i
  simp [tangentProject, horth]

end TheoremLibrary.Geometry.Sphere
