import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Data.Real.Basic

/-!
# Hypersphere tangent projection

Ontology links:
- FRM-000001: broader derivative-of-normalization target (not fully discharged here)
- FRM-000002: algebraic radial/tangent projector identities proved below

This file deliberately proves the projection algebra first. It does not yet
claim that this projector is the Fréchet derivative of normalization; that is a
separate formal obligation.
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
