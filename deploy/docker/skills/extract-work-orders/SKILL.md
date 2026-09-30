---
name: extract-work-orders
description: "Provides guidance and tools for extracting work orders from blueprints, requirements documents, or user requests. Helps identify discrete work items."
metadata:
  source: "https://factory.8090.ai/project/1b76bcb7-21cd-466d-b708-2ded828bb0f7/skills/work_order_extraction"
  extracted: "2026-09-30"
---

The user has updated requirements documents (the "what") and blueprints (the "how"). Your task is to identify and propose the work orders needed for the requested blueprint or requirements changes.

## Workflow

### Step 1: Determine Blueprints To Process

- If the user already specified which blueprints to extract from, use that selection and continue.
- If the blueprint selection is unclear, use the question tool to ask "What blueprints do you want to extract work orders from?" with these options:

  - **Option 1**: Current blueprints only
  - **Option 2**: All blueprints
  - **Option 3**: Specific blueprints I will choose
  - **Option 4**: I will describe the scope
- If the user chooses to specify blueprints or describe the scope, use their free-response input as the blueprint selection.

For each selected blueprint:

### Step 2: Gather Context

- Read the blueprint content and understand the requested changes.
- Read the requirements document that is tied to the blueprint to get the set of specific requirements and acceptance criteria.

### Step 3: Determine What Work is Needed

- List the existing work orders linked to this blueprint and read each one to understand its full scope.
- Search the project for existing work orders related to this blueprint's scope.
- Compare the blueprint content against existing work orders to identify what's new.
- You may also search the codebase to see what functionality is already implemented.

### Step 4: Present Findings

Give a few sentence summary of what changed, and what work orders you recommend creating. When recommending work orders, only provide the titles of the work orders you recommend and a one sentence summary.

### Step 5: Get User Confirmation

Present your proposed work orders and ask for approval before creating them.

### Step 6: Execute

Once confirmed, create the work orders and link them to the source blueprint and any other relevant context.

## Communication Guidelines (CRITICAL)

- NEVER mention tool names in your responses
- NEVER expose internal UUIDs to users - use human-readable names instead
- Keep technical implementation details hidden - summarize findings in user-friendly language
- Focus on WHAT you found and WHAT you recommend, not HOW you found it
- When referencing blueprints, requirements documents, or work orders, use their titles, not IDs

**Good example:** "I reviewed the selected blueprints. The Authentication Flow blueprint has significant changes that need new work orders..."

**Bad example:** "I read the blueprint with ID a1c1ab9d... and the work order lookup returned..."
