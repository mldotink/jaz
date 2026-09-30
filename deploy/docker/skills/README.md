# Bundled customer-planning skills

Six full instruction sets extracted from the 8090 Software Factory project on 30 September 2026. Each `SKILL.md` includes its original description and source URL. The instruction bodies retain the source wording; editor controls were removed and formatting converted to Markdown.

| Skill | Use |
| --- | --- |
| [Plan](plan/SKILL.md) | Compare migration approaches, recommend one, and identify dependencies and validation. |
| [Requirements Writing Rules](requirements-writing-rules/SKILL.md) | Define capabilities, terminology, user stories, and acceptance criteria. |
| [Blueprints Writing Rules](blueprints-writing-rules/SKILL.md) | Describe architecture, components, contracts, and technical decisions. |
| [Extract Work Orders](extract-work-orders/SKILL.md) | Derive execution work from requirements and blueprints while checking existing work. |
| [Work Orders Writing Rules](work-orders-writing-rules/SKILL.md) | Scope work and carry the applicable requirements and acceptance criteria into each order. |
| [Phase Planning](phase-planning/SKILL.md) | Sequence work according to dependencies and assign it to existing phases. |

## Local use

Ask an agent to read the relevant `SKILL.md` files explicitly. For a migration definition, use Plan, then Requirements Writing Rules and Blueprints Writing Rules. For execution planning, add Extract Work Orders, Work Orders Writing Rules, and Phase Planning as needed. The image installs these files into the Jaz skill catalog at `/var/lib/jaz/skills` and the Codex skill directory at `/var/lib/jaz/acp/codex-home/skills`. Jaz also installs catalog skills into supported agent profiles when they launch. Existing skill directories on persistent volumes are preserved.

The source assumes 8090 project documents and tools. Locally, read and write Markdown documents or use the project tools actually available. Resolve `@EntityName` references to document titles and file links; retain `#ComponentName`, element names, and requirement IDs consistently. Treat `phase_number` as work-order metadata only when the local project supports it. When no phases exist, propose a sequence and identify that gap rather than claiming assignments were saved.

The source's approval rules apply within the user's current authorization. A request to create a migration plan and documents already authorizes those deliverables. Platform access, actual migration execution, and production cutover require the corresponding scope and access.

These are general planning and documentation skills. Supply the migration problem, inventory, constraints, and platform evidence separately; the skills contain no Databricks or Snowflake implementation recipe. Extraction alone has not migrated any workloads.

`8090-provenance.json` records source URLs and hashes of the captured editor HTML and final skill files.
