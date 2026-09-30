---
name: blueprints-writing-rules
description: "Writing guidelines for blueprints. Must be read prior to editing or creating blueprints"
metadata:
  source: "https://factory.8090.ai/project/1b76bcb7-21cd-466d-b708-2ded828bb0f7/skills/blueprints_writing_rules"
  extracted: "2026-09-30"
---

## Writing Guidelines for Containers

# Container Blueprint Writing Instructions

## What a Container Blueprint Documents

A Container Blueprint documents a single C4 container — a deployable runtime process (web app, API server, background worker, database, pipeline, etc.). It covers the container's tech stack, deployment model, how work enters it, and the contracts it exposes to other containers and systems. It is not a list of features; it is a description of the boundary, the platform it runs on, and the guarantees it makes.

Container Blueprints complement Component Blueprints: Component Blueprints document the runtime capabilities *inside* a container; Container Blueprints document the container *itself* — its infrastructure, entry points, and integration contracts.

## Mention Syntax

Three mention types create navigable links:

- **`#ComponentName`** — Runtime components that live inside this or other containers. Use when describing which components own an entry point or implement a contract.
- **`` `ElementName` ``** — Schemas, configs, domain types, enums, API contracts, message formats. Things that *describe shape*. Use source-language casing.
- **`@EntityName`** — Platform entities: Blueprints, Requirements, Work Orders, Artifacts.

## Blueprint Structure

1. **Title** — Container name as `# Heading` (e.g., `# API Server`, `# Client App`)
2. **`## Container Summary`** — What this container is (web app, API server, worker, database, pipeline), the main tech stack, and the high-level role it plays in the system. 2–4 sentences.
3. **`## Infrastructure`** — Runtime environment and deployment/orchestration model (e.g., containerised on ECS, serverless Lambda, managed Postgres). Key platform dependencies: datastores, queues, caches, external services this container depends on to run.
4. **`## Entry Points and Boundaries`** — How work enters this container: HTTP/gRPC endpoints, queue consumers, scheduled jobs, webhooks, CLI commands. Describe the primary boundaries this container exposes to other containers and systems. Use `#Component` to name the components that own each entry point.
5. **`## System Contracts`** — Three sub-sections:

   - **`### Key Contracts`** — Operational guarantees at the container boundary: availability expectations, authn/z requirements, idempotency, ordering, consistency, retry behavior, and how errors are surfaced to callers.
   - **`### Integration Contracts`** — Events published/consumed, API interfaces, webhooks, and message formats that cross this container's boundary. Include `ElementName` references for schemas and message formats.
   - **`### Integration Boundaries`** — Ownership and separation of concerns between this container and other containers or external platforms. Call out notable trust, security, or data residency boundaries.
6. **`## Architecture Decision Records`** — Each entry is a `###` heading in the format `### ADR-NNN: Title`, followed by three labeled paragraphs: **Context** (why the decision was needed at the container level), **Decision** (what was chosen and how), **Consequences** (trade-offs, benefits, and implications). Number ADRs sequentially within the Blueprint.

## Writing Principles

- **Boundary-first** — Every section describes what is visible *across* the container boundary, not internal implementation detail. Internal wiring belongs in Component Blueprints.
- **Infrastructure-honest** — Name the actual runtime platform, orchestrator, and managed services. Avoid generic descriptions like "runs in the cloud".
- **Contract-precise** — System Contracts should be specific enough that another team could build a client without asking questions. Name schemas and message formats with `` `Element` `` mentions.
- **Component-linked** — Use `#Component` mentions to connect entry points and contracts to the components that implement them, creating a navigable bridge to Component Blueprints.

## Writing Guidelines for Components

# Component Blueprint Writing Instructions

## What a Component Blueprint Documents

A Component Blueprint documents a reusable, feature-agnostic system capability: a cohesive group of runtime components (services, controllers, hooks, strategies) that power one capability. The list of components and the description of how they interoperate may span multiple C4 containers (e.g., Task Server, API Server + Client App). `component` blocks are architecture nodes; prose paragraphs between them are relationship edges.

## Structured Blocks

### Component Block

Defines a runtime component (architecture node). Use inside `## Core Components`. Components MUST be written in the structured format below bounded by "```component" fences.

````
```component
name: PascalCase (matches code identity)
container: C4 container(s), comma-separated
responsibilities:
	- What this component does (tab-indented bullets)
	- Use `ElementName` for data/contracts, `#ComponentName` for collaborators
```
````

Any component defined in any Blueprint can be `#`-referenced from any other Blueprint.

### Model Block

Defines a canonical data/domain model central to implementation but not a runtime component. Use when an explicit, implementation-central model definition is needed. Models MUST be written in the structured format below bounded by "```model" fences.

````
```model
name: ModelName
store: Postgres | S3 | DynamoDb | CacheMemory | etc.
description: Short purpose statement
fields:
	- field_name: type (constraints)
constraints:
	- Invariant rules enforced by domain logic
```
````

## Mention Syntax

Three mention types create navigable links:

- **`#ComponentName`** — Components: services, controllers, hooks, strategies, providers. Things with `component` blocks that *do work*. Cross-blueprint `#` references express composition.
- **`` `ElementName` ``** — Elements: schemas, configs, domain types, enums, request/response models, exceptions, feature flags, models defined via `model` blocks. Things that *describe shape*. Use source-language casing.
- **`@EntityName`** — System entities: other Requirements, Blueprints, Work Orders, Artifacts managed by the platform.

**Rule:** Does work (processes, orchestrates, renders, fetches) → `#Component`. Describes shape/contract → `` `Element` ``. Platform document/entity → `@Entity`.

## Relationship Paragraphs

Prose paragraphs between component blocks are architecture edges. Each paragraph:

- Connects concrete components — mention both `#` names early so the edge is explicit
- States direction (who depends on whom)
- Uses `#Component` and `` `Element` `` mentions for data-flow clarity
- Explains *why* the interaction exists, not just *what*
- One relationship per paragraph, 2–4 sentences
- Does NOT restate component block responsibilities — describes the *interaction* and what crosses the boundary

## Blueprint Structure

1. **Title** — Blueprint title as `# Heading`
2. **`## Capability Summary`** — 2–3 sentences explaining what the capability does, naming key elements flowing through it
3. **`## Core Components`** — Component blocks grouped logically. Use `###` subheadings for groups (e.g., "### API Layer", "### Frontend: Hooks"). Use `---` between major boundaries when visual separation helps. Insert relationship paragraphs between components/groups when direction, data flow, or intent is not obvious from colocation.
4. **`## System Contracts`** — Organize in bullet lists as `### Key Contracts` (invariants, idempotency, ordering, consistency, retry) and `### Integration Contracts` (events published/consumed, API interfaces, webhooks, composition expectations). Use component and element mentions where necessary.
5. **`## Architecture Decision Records`** — Each entry is a `###` heading in the format `### ADR-NNN: Title`, followed by three labeled paragraphs: **Context** (why the decision was needed), **Decision** (what was chosen and how), **Consequences** (trade-offs, benefits, and implications). Number ADRs sequentially within the Blueprint.

**When to create:** Shared system that two or more features depend on; reusable capability being abstracted; enough internal structure (multiple components + relationships) for its own document. **Don't create for:** single utility with no internal structure; feature-specific logic belonging in one context.

## Writing Guidelines for Feature Blueprints

# Feature Blueprint Writing Instructions

## What a Feature Blueprint Documents

A Feature Blueprint documents how shared Component Blueprint capabilities compose to satisfy a set of Requirements, adding feature-specific components only where needed. Shared capabilities do the heavy lifting; the Feature Blueprint wires them together, configures their behavior, and documents any feature-only glue. Each Feature Blueprint corresponds to a Feature Requirements Document.

**Relationship to Component Blueprints:** (1) Identify shared capabilities between features → document as Component Blueprints. (2) Compose capabilities into Feature Blueprints mapping onto Requirements. (3) Feature-specific components exist where needed. Components often start in Feature Blueprints and migrate to Component Blueprints when reuse emerges.

## Mention Syntax

- **`#ComponentName`** — runtime components that *do work*
- **`` `ElementName` ``** — schemas, configs, types that *describe shape*
- **`@EntityName`** — platform entities: Requirements, Blueprints, Work Orders, Artifacts

## Blueprint Structure

1. **Title** — Blueprint title as `# Heading`
2. **`## Feature Summary`** — 2–3 sentence user-centered summary referencing the corresponding Requirements Document
3. **`## Component Blueprint Composition`** — Which shared capabilities this feature composes and how each is configured/scoped. Use `@Blueprint` for referenced Blueprints and `#Component` for concrete runtime components. Don't redefine shared components — describe *how the feature uses* the capability (scoping, configuration, transformations). Use composition paragraphs to explain how each capability wires into the feature, stating direction and data flow.
4. **`## Feature-Specific Components`** — Full component blocks for components existing only for this feature. Use relationship paragraphs between component blocks when direction, data flow, or intent is not obvious from colocation.
5. **`## System Contracts`** — Organize in bullet lists as `### Key Contracts` (invariants, correctness rules, reliability semantics) and `### Integration Contracts` (events, APIs, composition expectations specific to this feature). Use component and element mentions where necessary.
6. **`## Architecture Decision Records`** — Each entry is a `###` heading in the format `### ADR-NNN: Title`, followed by three labeled paragraphs: **Context**, **Decision**, **Consequences**. Number ADRs sequentially within the Blueprint.

**Requirements connection:** Always read the corresponding Requirements Document before writing. Every major requirement theme should have a clear technical path through the Blueprint.
