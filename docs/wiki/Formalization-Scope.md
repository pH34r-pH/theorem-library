# Formalization scope

Theorem Library formalizes claims that can materially narrow the research space.

## Good candidates

A result belongs here when a machine-checkable proof can:

- settle a mathematical property that would otherwise motivate unnecessary experiments;
- expose a hidden assumption;
- rule out a proposed mechanism as stated;
- distinguish a local operator fact from a global/recurrent claim;
- create a reusable formal checkpoint for multiple research notes.

## What does not automatically belong here

Empirical measurements, model-training results, literature summaries, active hypothesis queues, and private theorem-ledger lifecycle state are not public-library content simply because mathematics is involved.

## Local versus global claims

A recurring failure mode is promoting a true local theorem into a stronger systems claim.

For example, the exact derivative of normalization is a local mathematical fact. A multi-layer or recurrent network may mix directions before or after that normalization. The formal library therefore includes composition boundaries rather than assuming the local result automatically propagates through the system.

## Scientific correspondence

The formal theorem and the empirical claim remain separate artifacts. Research Notes documents why a theorem matters to an experiment and what stronger interpretation does not follow.
