# PUBLIC-CORE inventory

The current public core is deliberately narrower than the complete private formal campaign. It contains reusable hypersphere-normalization mathematics whose disclosure does not expose the active experimental frontier.

## Included modules

- `TheoremLibrary.Geometry.Sphere.Projection`
- `TheoremLibrary.Geometry.Sphere.NormDerivative`
- `TheoremLibrary.Geometry.Sphere.Normalization`
- `TheoremLibrary.Geometry.Sphere.Anisotropy`
- `TheoremLibrary.Geometry.Sphere.ScaleInvariantLoss`
- `TheoremLibrary.Geometry.Sphere.RadialMemory`
- `TheoremLibrary.Geometry.Sphere.NormalizationSpectrum`
- `TheoremLibrary.Geometry.Sphere.NormalizationComposition`
- `TheoremLibrary.Geometry.Sphere.NormalizationGradient`

All reusable public declarations live under `TheoremLibrary.*`. Stable `FRM-*` / `LIB-*` identifiers preserve cross-repository theorem identity independently of module paths.

## Included infrastructure

- pinned Lean and Mathlib versions;
- reproducible Lake manifest;
- selective Mathlib cache bootstrap;
- incremental development build helper;
- independent `leanchecker` validation;
- source placeholder audit;
- pinned axiom audit;
- GitHub Actions validation workflow.

## Not included

The private theorem ledger, ontology/provenance graph, experiment-specific correspondence, clean-room promotion receipts, active conjecture queue, and formal modules whose release would reveal unpublished research strategy remain in `domain-scaling-lab` under the research-specific `DomainScaling.*` namespace.

The boundary can expand milestone by milestone. Moving a theorem here changes where its public proof source lives; it does not transfer ownership of scientific lifecycle state out of the private ledger.
