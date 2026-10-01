import TheoremLibrary.Geometry.Sphere.Projection
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.NormNum

/-!
# Mutation-testing fixture

This file is a small, repository-local fixture for the upstream
`jubnzv/Mutate.lean` Lean mutation-testing tool. It imports and tests the
actual public `tangentProject`; it does not duplicate or replace that
definition. The strengthened mixed-direction property is intentionally kept
here as specification feedback rather than added to the public theorem index.

The upstream runner remains an external developer tool until its source
license is clarified. See `docs/wiki/Verification.md` for the exact
compatibility and licensing boundary.
-/

namespace TheoremLibrary.MutationBaseline

open TheoremLibrary.Geometry.Sphere

abbrev Vector := Fin 2 → ℝ
abbrev Projection := Vector → Vector → Vector

def axis0 : Vector := fun i => if i = 0 then 1 else 0

def axis1 : Vector := fun i => if i = 1 then 1 else 0

def radialProperty (project : Projection) : Prop :=
  project axis0 axis0 = 0

def tangentProperty (project : Projection) : Prop :=
  project axis0 axis1 = axis1

def mixedAdditivityProperty (project : Projection) : Prop :=
  project axis0 (axis0 + axis1) = project axis0 axis0 + project axis0 axis1

def mixedWitnessFactor : Vector → ℝ := fun v => v 0 * v 1

/- The fixture calls the production definition directly. The zero term is a
   deliberate mutation site: it is invisible to the radial/tangent witnesses
   below but the mixed-direction property rejects its nonzero mutation. -/
def projectionFixture : Projection := fun u v =>
  tangentProject u v + (0 : ℝ) • (mixedWitnessFactor v • v)

def gapMutation : Projection := fun u v => fun i =>
  v i - euclideanDot u v * v i

example : radialProperty tangentProject := by
  exact tangentProject_radial axis0 (by
    norm_num [axis0, euclideanDot])

example : tangentProperty tangentProject := by
  exact tangentProject_tangent axis0 axis1 (by
    norm_num [axis0, axis1, euclideanDot])

theorem projection_fixture_radial : radialProperty projectionFixture := by
  unfold radialProperty projectionFixture
  funext i
  fin_cases i <;> norm_num [axis0, mixedWitnessFactor, tangentProject, euclideanDot]

theorem projection_fixture_tangent : tangentProperty projectionFixture := by
  unfold tangentProperty projectionFixture
  funext i
  fin_cases i <;> norm_num [axis0, axis1, mixedWitnessFactor, tangentProject, euclideanDot]

theorem projection_fixture_mixed_additivity : mixedAdditivityProperty projectionFixture := by
  unfold mixedAdditivityProperty projectionFixture
  funext i
  fin_cases i <;> norm_num [axis0, axis1, mixedWitnessFactor, tangentProject, euclideanDot]

example : radialProperty gapMutation ∧ tangentProperty gapMutation := by
  constructor
  · unfold radialProperty gapMutation
    funext i
    fin_cases i <;> norm_num [axis0, euclideanDot]
  · unfold tangentProperty gapMutation
    funext i
    fin_cases i <;> norm_num [axis0, axis1, euclideanDot]

example : ¬ mixedAdditivityProperty gapMutation := by
  intro h
  have h1 := congrFun h 1
  norm_num [mixedAdditivityProperty, gapMutation, axis0, axis1, euclideanDot] at h1

end TheoremLibrary.MutationBaseline
