# ADR-001: Feature-Based Package Structure

## Status

Accepted

## Context

We need to decide how to organize the Spring Boot backend packages. The two main options are:

1. **Layer-based**: Group by technical layer (all controllers together, all services together, etc.)
2. **Feature-based**: Group by business domain (user, product, order — each with its own controller, service, repository)

## Decision

We chose **feature-based** organization.

## Consequences

**Positive:**
- Each feature module is self-contained and easy to find
- Scales well — adding a new feature means adding a new package
- Easier to extract into microservices later if needed
- Better encapsulation — feature internals are not exposed globally

**Negative:**
- Some code duplication across feature modules (e.g., similar mapper patterns)
- Shared concerns (e.g., base entities) need a `common/` package
