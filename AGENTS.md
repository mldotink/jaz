# Leeroo Ink deployment

- Ink runs in Leeroo’s AWS account `221082199974`, EKS cluster `uniforge-ink-eks` in `us-east-1`.
- Kubernetes context: `uniforge-aws`; AWS profile: `majid-ink`.
- Ink API: `https://api.apps.uniforge.leeroo.com/graphql`.
- Workspace: `august`; project: `default`.
- Service: `jaz-mast-v5` (`RFTiTTRs9ixGzwQPPSGzkn`).
- Endpoint: `https://jaz-mast-v5.ink.apps.uniforge.leeroo.com` (Leeroo organisation SSO).
- Data volume: `/var/lib/jaz`, existing 25 GiB volume retained.
- Image repository: `221082199974.dkr.ecr.us-east-1.amazonaws.com/leeroo-jaz`.
- Deployed image digest: `sha256:bf06b9d8225334f815f4d6372f5dcb3cb19c88006eaf4f5f4d7d72abffb49608`, tag `09a1ddc`.
- Jaz source: `fc6dfb83a820b1fcde2c3cece4eb14171237d913`, including inline questions, saved answers, partial submission and Bots.
- Six extracted 8090 planning skills are bundled under `deploy/docker/skills`.

Ink-owned build repositories are reserved for platform builds. Publish external
service images into the dedicated `leeroo-jaz` repository and deploy through the
Leeroo Ink API. The connected Deployink MCP points at Ink Cloud, a separate
installation.

- Live Codex defaults: built-in `openai-api-key`, `gpt-6-sol`, `medium`, saved and read back on 2026-10-01. Source configuration matches for future builds. The deployed image originally seeds `gpt-6-astra` once; later user settings are preserved.
- The deployed OpenAI project key returns `401 invalid_api_key`; a valid replacement is required for real answers.
- Core capability fix `c39a7033` is isolated on `jaz/leeroo-codex-config-fix`, not merged or deployed.
