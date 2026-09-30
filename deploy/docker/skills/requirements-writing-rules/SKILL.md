---
name: requirements-writing-rules
description: "Writing guidelines for requirements. Must be read prior to editing or creating requirements"
metadata:
  source: "https://factory.8090.ai/project/1b76bcb7-21cd-466d-b708-2ded828bb0f7/skills/requirements_writing_rules"
  extracted: "2026-09-30"
---

## Feature Requirements Writing Instructions

### General Writing Rules

Use active voice and concrete language. Avoid fluffy adjectives like "comprehensive," "sophisticated," "seamless," "powerful," or "engaging."

Focus on *what* the feature should do, not *how* it's built — implementation belongs in blueprints. Likewise, do not prescribe the exact surface the user or caller encounters — fonts, hex values, and pixel positions, or response schemas and status codes. Describe the communicative intent instead — e.g., "visually indicates that the item is unsaved." Designers and engineers translate intent into surface form; requirements stop at intent.

### Section Guidelines

#### Overview

Write 1-2 narrative paragraphs explaining what the feature does and why users need it; a stakeholder should grasp its purpose in under a minute. Focus on the problem solved and the value delivered, not mechanisms or implementation.

#### Terminology

Terminology rigor is crucial. Clear and consistent terms let an agent search and refer to related documentation across the full SDLC.

Every named entity a requirement discusses must be defined here. The test is symmetric — every named entity in the Requirements section has an entry here, and every entry here is used.

Define each term by what it does and the primary intent it serves, not by where it appears on the screen. "Version Document Navigator: a panel containing the lists of nested documents for a particular version in the Version History view" tells a reader what the thing is for. "The panel on the left of Version History" tells them nothing and breaks the moment the layout changes.

When a term is already defined formally in another document, don't redefine it; still list it here as a one-line reference naming the document that owns the definition.

#### Requirements

A requirement is one capability the system must provide, expressed as a user story paired with the acceptance criteria that define when that story is done. The user story is the human framing — "As a [role], I want [action], so that [outcome]" — naming who wants the capability and why.

Each acceptance criterion is a binary, observable assertion — it passes or fails on inspection, with no judgment call — describing externally visible behavior, not internal mechanism. Together the criteria fix the requirement's boundaries, covering the normal path plus the variations, edge cases, and failures of the same capability.

Neither half stands alone: a story without criteria cannot be verified, and criteria without a story serve no outcome. A requirement states intent — what must be true — and stops short of how.

Each requirement follows this structure:

- **Requirement ID**: Use format `REQ-[FEATURE-ACRONYM]-NNN` (e.g., `REQ-AUTH-001`). Child features append their own suffix (e.g., `REQ-AUTH-PR-001` for Password Reset under Auth).
- **Requirement Name**: A brief descriptive title.
- **User Story**: "As a [role], I want to [action], so that I can [outcome]."
- **Acceptance Criteria**: Use format `AC-[FEATURE-ACRONYM]-NNN.N`, written in the syntax described below.

Requirements must be atomic (one cohesive capability each) and independently testable.

## Writing a Single Requirement Well

### Keep Each Requirement Atomic

A requirement describes one cohesive capability pursued by one role for one outcome. If you find yourself stacking unrelated acceptance criteria under a single user story — criteria for creating, filtering, and deleting items — you have merged multiple requirements. Split them. Atomic requirements are easier to review and test, and make for better separation of concerns in work orders.

### Decide What Is a Separate Requirement and What Is an Acceptance Criterion

A requirement and its acceptance criteria answer two different questions. The requirement names one capability — one role pursuing one outcome. The acceptance criteria enumerate the conditions under which that capability is correct: its normal path, variations, edge cases, and failure modes. Several criteria under one requirement is the expected case, not a smell — they are all facets of the same behavior.

You have a second requirement, not another criterion, when the behavior changes on one of three axes: a different role acts, a different action triggers it, or it produces a different outcome. The sharpest test is independence — if it could be built, tested, enabled, or removed on its own without changing the first, it is its own requirement. On the same screen, "filter the list" and "delete an item" are two requirements (different actions and outcomes), while "show a count," "show an empty state," and "show an error when loading fails" are three criteria of one capability — displaying the list.

When unsure, state the capability in one sentence with one verb; if you need "and," you likely have two requirements.

### Acceptance Criteria Syntax

Every pattern ends in a "shall" clause naming the entity and the observable response; the clauses before it set the conditions under which that response applies.

Choose the pattern that matches the behavior:

- **Ubiquitous** — a behavior that is always active, with no condition. "The [entity] shall [observable response]." Use this for invariants that hold at all times, e.g. "The session token shall expire 30 minutes after it is issued."
- **State driven** — a behavior that holds as long as a state remains true, denoted by *While*. "While [precondition], the [entity] shall [observable response]." Use this for continuous behavior tied to a state rather than a moment, e.g. "While the document is loading, the view shall display a loading indicator."
- **Event driven** — a response to a triggering event, denoted by *When*. "When [trigger], the [entity] shall [observable response]." e.g. "When the user enters text in the filter field, the list shall show only the items whose name contains that text."
- **Optional feature** — a behavior that applies only where a feature is present, denoted by *Where*. "Where [feature is included], the [entity] shall [observable response]." e.g. "Where the workspace has single sign-on enabled, the login screen shall offer a single sign-on option."
- **Unwanted behavior** — the required response to an error or undesired situation, denoted by *If* and *Then*. "If [trigger], then the [entity] shall [observable response]." e.g. "If the credit card number fails validation, then the form shall display a re-entry message."
- **Complex** — a combination of the patterns above when richer behavior demands it, with the keywords in temporal order. "While [precondition], when [trigger], the [entity] shall [observable response]."

Keep one condition and one observable response per criterion. If the response clause needs "and" for two behaviors, split it into two criteria.

### When You Name a Surface or Boundary, Define What's On It

The first time a requirement introduces a container that holds other things — a panel, dialog, or view in a web app, or a subcommand in a CLI — enumerate what appears inside it by default. For example, "When the user opens the share dialog, the dialog shall display a link field, a permission selector, and a copy button". Items inside earn their own requirements only when their behavior needs independent acceptance criteria — when they open a sub-flow, have distinct permission rules, or behave differently from their neighbors.

### State the Default Whenever Something Is Configurable

For every setting, toggle, flag, sort order, filter, view selection, or option set, specify the default in effect before anything changes it.

### Cover Non-Default Scenarios Explicitly

Requirements that cover only the happy path are incomplete. Enumerate the alternate paths the same surface must handle — unexpected adjacent actions, a precondition assumed elsewhere that isn't true here, or two requirements interacting at the same surface. Some scenarios get missed most often and deserve a deliberate pass:

- **Data states**: empty, loading, stale, unavailable, failed, or successfully loaded.
- **Failure and recovery**: validation errors, permission denials, network or server failures, timeouts, cancellations, retries, and partial failures.
- **Concurrency and multi-actor behavior**: multiple users, sessions, tabs, processes, or devices interacting with the same data at the same time, including conflicts and visibility updates.
- **Scale and limits**: zero, one, many, or extremely large numbers of items, plus pagination, input limits, unusual content, and capacity constraints.
- **Lifecycle and reversibility**: delete and archive behavior, undo and recovery flows, cascading side effects, duplicate submissions, expiration, and scheduled or deferred actions.
- **Persistence and navigation**: what is saved, discarded, restored, committed, or canceled across refreshes, navigation, logout, restarts, crashes, and device changes.

### Order the Way a Reader Builds Understanding

Order the Requirements section the way a reader builds understanding from the outside in. Start with the entry point and initial state: how the user enters the feature, what's shown by default, and anything consistent across all modes or components.

A reader moving top to bottom should never hit a requirement that assumes a flow defined later — the common failure is describing how the user edits an item before any requirement says how it is created or opened. Lead with what the user sees first, then what they can do from there, so each requirement stands on ground the previous ones laid.

Then break out by key component — usually the major Terminology entities. Give each its own subheading and lead with the primary user journeys before covering edge behaviors. After the key components, capture cross-component interactions, then close with smaller bespoke capabilities. Using component names as subheadings keeps the document scannable and reinforces terminology.

### Watch for Terminology Collisions Across Requirements

Within a document, scan related requirements for collisions — the same word used for two different things destroys alignment and makes review painful. When two requirements refer to similar-but-distinct concepts, give them distinct names and define both in Terminology. Never use shortnames or abbreviations for any entity.

## Organizing Requirements Across the Document and Feature Tree

### Organize by Feature, Not by Initiative

An initiative's scope often spans multiple features, and the temptation is to dump every requirement into one document because that matches the current work. Resist it. Spread requirements across the features they belong to, cross-reference where the relationship matters (without redefining anything), and update the related Work Order to capture cross-feature references for delivery.

### Place Each Requirement in the Right Place in the Feature Tree

A parent feature should capture the core essence of a capability; children are enhancements that build on it and cannot exist without it. The parent must stand alone; the child must not. Do not create a child feature with the same name as the parent.

A key example is a family of siblings sharing a container — view-switcher tabs in a web app, or sibling subcommands in a CLI. Whether they belong in one feature or split into children depends on their density and difference. When they share a similar nature and differ only modestly, they belong in one feature alongside the container. When each sibling is dense with its own behavior — for example, the Timeline, Roadmap, and Table views of a ticketing system — split each into its own child feature.

## Overview Document Writing Instructions

Product overview documents capture high-level strategic context that guides the entire project. Write in an executive summary style using narrative prose—not terse bullets.

## Writing Approach

- Write in complete paragraphs that tell a story and provide context.
- Defend the problems and needs being addressed with clear rationale.
- Capture the current state, gaps, and why change is necessary.
- Explain the value proposition and expected outcomes.
- Write for stakeholders who need to understand the "why" before the "what".

## Common Document Types

Overview documents can address various focus areas. Common examples include Business Problem, Current State, Product Description, Success Metrics, Personas and Technical Requirements—but users may create additional overview documents as needed for their project.

Regardless of the specific type, each overview document should provide enough narrative context for stakeholders to understand the topic's importance and how it fits into the overall project vision.
