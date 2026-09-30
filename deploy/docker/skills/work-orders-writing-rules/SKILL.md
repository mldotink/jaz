---
name: work-orders-writing-rules
description: "Writing guidelines for work orders. Must be read prior to editing or creating work orders"
metadata:
  source: "https://factory.8090.ai/project/1b76bcb7-21cd-466d-b708-2ded828bb0f7/skills/work_orders_writing_rules"
  extracted: "2026-09-30"
---

### Scoping Guidelines

Split work orders by technical layer (e.g., backend, frontend, database) so developers with different specialties can work in parallel.

Each work order should:

- Target a single technical layer (e.g., backend, frontend, database)
- Be buildable and testable without waiting on other work orders
- Be limited in scope (generally 5-10 files)

Analyze complexity and break down appropriately:

- Simple blueprints → Create 1 work order
- Complex blueprints (too many files, too many dependencies, or multiple distinct concerns) → Create multiple work orders, each focused on a unit of development
- Consider natural separation points (data model, API, UI, validation, etc.)

### Title Guidelines

Title is action-oriented and specific.

### Description Guidelines

A work order description must give a developer everything required to implement the feature without ambiguity or scope drift. It should be precise, implementation-oriented, and free of unnecessary explanation.

Include only the following sections:

### **Summary**

- Clearly answer: "What is being built or changed?"
- State the outcome this work order enables.
- Focus on value and system impact, not background explanation.
- 2-3 sentences maximum.

### **In Scope**

- Explicitly list the responsibilities owned by this work order.
- Define functional boundaries.
- Do not restate acceptance criteria verbatim.
- Avoid low-level implementation steps.

### **Out of Scope**

- Explicitly list what is excluded or deferred.
- Clarify boundaries with adjacent work orders.
- Prevent scope creep.

### **Requirements**

- Copy the requirements and acceptance criteria verbatim from the requirements document.
- Include every requirement and every acceptance criterion that falls within this work order's scope.
- Use identical formatting and IDs.
- Do not modify wording.
- If only a subset applies, include only the applicable acceptance criteria.
- Do not add interpretation or commentary.

Format:

```
## Requirements

### REQ-{PREFIX}-{NNN}: {Requirement Title}

**User Story:** {Verbatim user story from the requirements document}

**Acceptance Criteria:**
- AC-{PREFIX}-{NNN}.{N}: {Verbatim criterion text}
- AC-{PREFIX}-{NNN}.{N}: {Verbatim criterion text}
- ...

### REQ-{PREFIX}-{NNN}: {Next Requirement Title}
...
```

### **Blueprints**

Name the source blueprint(s) that inform implementation. Keep this minimal — the implementer will read the full blueprints directly.

```
## Blueprints

- {Component Blueprint Name} — {one-line summary of what it covers}
- {Another Component Blueprint Name} — {one-line summary}
```
