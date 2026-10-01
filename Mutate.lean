import TheoremLibrary.Geometry.Sphere.Projection
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.NormNum

/-!
# Mutation-testing baseline

This file is a deliberately small, standalone specification baseline for
`TheoremLibrary.Geometry.Sphere.tangentProject`.  The runner mutates only the
marked local definition, then asks Lean to elaborate the concrete property
checks below.  A successful elaboration is a survivor; a failed elaboration is
a killed mutant.  Lean's kernel remains the verifier for both the baseline and
the counterexample proofs.

The two baseline properties exercise the radial and tangent channels already
documented by the public projection module.  The strengthened mixed-direction
property is kept separate so a survivor can be inspected as specification
feedback rather than hidden by an unconditional mutation score.

This is evidence about this small finite witness suite.  It is not a claim
about trained models, arbitrary recurrences, or the completeness of the
projection API.
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

def mutationTarget : Projection := fun u v => fun i =>
  v i - euclideanDot u v * u i -- MUTATION_TARGET

def gapMutation : Projection := fun u v => fun i =>
  v i - euclideanDot u v * v i

def equivalentNoiseMutation : Projection := fun u v => fun i =>
  v i - euclideanDot u v * u i + 0

-- BEGIN BASELINE TESTS

example : radialProperty mutationTarget := by
  unfold radialProperty mutationTarget
  funext i
  fin_cases i <;> norm_num [axis0, euclideanDot]

example : tangentProperty mutationTarget := by
  unfold tangentProperty mutationTarget
  funext i
  fin_cases i <;> norm_num [axis0, axis1, euclideanDot]

-- END BASELINE TESTS

-- BEGIN STRENGTHENED PROPERTY

example : mixedAdditivityProperty mutationTarget := by
  unfold mixedAdditivityProperty mutationTarget
  funext i
  fin_cases i <;> norm_num [axis0, axis1, euclideanDot]

-- END STRENGTHENED PROPERTY

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

example : radialProperty equivalentNoiseMutation ∧
    tangentProperty equivalentNoiseMutation := by
  constructor
  · unfold radialProperty equivalentNoiseMutation
    funext i
    fin_cases i <;> norm_num [axis0, euclideanDot]
  · unfold tangentProperty equivalentNoiseMutation
    funext i
    fin_cases i <;> norm_num [axis0, axis1, euclideanDot]

end TheoremLibrary.MutationBaseline
