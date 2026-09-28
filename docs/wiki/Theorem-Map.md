# Theorem map

The current public core forms a dependency chain rather than a bag of unrelated facts:

```text
norm derivative
     |
normalization derivative
     |
radial / tangent geometry
     |
kernel / range / rank / spectrum
     |
composition and gradient boundaries
     |
scale-invariant / radial-memory consequences
```

## Normalization derivative

The library formalizes the derivative of `x / ||x||` away from the origin and its projection-like radial/tangent structure.

## Radial and tangent behavior

Radial perturbations are annihilated by the local normalization derivative; tangent perturbations have an exact inverse-radius gain.

## Spectral structure

Finite-dimensional results characterize kernel, range, rank, and singular values.

## Loss and gradient consequences

The public core records exact consequences for differentiable losses composed with normalization, while keeping assumptions explicit.

## Information boundary

Positive rescalings that map to the same normalized state establish one precise kind of information loss at a normalization boundary. This does not imply all information ever associated with radius disappears from a surrounding recurrence.

## Composition boundary

The library records conditions under which local radial/tangent conclusions do or do not survive surrounding maps.

For stable theorem identifiers, names, statements, and source files, [INDEX.md](https://github.com/pH34r-pH/theorem-library/blob/main/INDEX.md) is authoritative.
