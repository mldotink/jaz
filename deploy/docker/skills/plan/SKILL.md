---
name: plan
description: "Use when the user asks to plan, design, or compare approaches before creating or changing requirements, blueprints, work orders, or implementation. Also use when the change may affect multiple different project entities, or when the user wants to add substantial new product functionality with multiple valid approaches and significant trade-offs."
metadata:
  source: "https://factory.8090.ai/project/1b76bcb7-21cd-466d-b708-2ded828bb0f7/skills/plan"
  extracted: "2026-09-30"
---

# Plan Mode

Plan Mode is a read-only collaborative mode for shaping an approach before changing project artifacts or implementation. It helps when committing to the wrong path would be expensive.

## When NOT to use Plan Mode

- The task is straightforward with an obvious next edit
- You're already executing an approved approach and making good progress
- A minor clarifying question suffices, so just ask it
- The task is a small direct edit, rename, or configuration change

## Hard rules

- Plan Mode is read-only. Do not make edits, create files, or run mutating commands.
- Do not produce plans so detailed they become pseudocode. The plan should guide decisions, not dictate every line.
- Plans require user approval before execution. Do not start implementing until you have clarified the approach and asked the user if they want to proceed, and the user has approved.
- Once the user approves the plan and you begin execution, keep a todo list to track your progress through the approved steps. Keep it current as steps move from pending to in\_progress to completed.

## How to plan well

### 1. Understand the problem space

Read relevant documents, work items, code, and context before proposing anything. Use available exploratory tools to understand existing patterns, conventions, and constraints. Identify:

- What exists today (current state of requirements, blueprints, work orders, and implementation)
- What the user wants to achieve (the delta, not a restatement of the ask)
- What constraints matter (scope, dependencies, backward compatibility, team conventions)

### 2. Present options with trade-offs

When multiple approaches exist, present 2–3 concrete options. For each:

- One-line summary of the approach
- Key trade-off (what you gain vs what you pay)
- When this option is the right choice

Use a comparison table when dimensions are parallel across options. Use prose when trade-offs are qualitative or context-dependent.

Avoid listing more than 3 options; decision fatigue helps nobody. If there are many viable paths, pre-filter to the strongest candidates and mention you narrowed the field.

### 3. Make a recommendation

Always recommend one option. "It depends" is not a plan. State which option you recommend and why, given what you learned about the codebase and the user's constraints. The user can override, but they shouldn't have to do your thinking.

### 4. Scope the work

After the approach is chosen, break it into concrete steps:

- What entities will be created or modified (requirements, blueprints, work orders, code)
- What order the changes should happen in (dependencies first)
- What needs validation and how
- Any risks or things to watch for during execution

Keep steps actionable. "Improve the architecture" is not a step. "Split the payments container blueprint into separate billing and invoicing containers" is.
