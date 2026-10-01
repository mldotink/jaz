# Leeroo Ink deployment

- Ink runs in Leeroo’s AWS account `221082199974`, EKS cluster `uniforge-ink-eks` in `us-east-1`.
- Kubernetes context: `uniforge-aws`; AWS profile: `majid-ink`.
- Ink API: `https://api.apps.uniforge.leeroo.com/graphql`.
- Workspace: `august`; project: `default`.
- Service: `jaz-mast-v5` (`RFTiTTRs9ixGzwQPPSGzkn`).
- Endpoint: `https://jaz-mast-v5.ink.apps.uniforge.leeroo.com` (Leeroo organisation SSO).
- Data volume: `/var/lib/jaz`, existing 25 GiB volume retained.
- Image repository: `221082199974.dkr.ecr.us-east-1.amazonaws.com/leeroo-jaz`.
- Deployed image digest: `sha256:f76602b8b4788b206818a4e7da0dae7f17ecb04af3fc2ffd6470b2a223f854cb`, tag `234e3f0`.
- Jaz source: `fc6dfb83a820b1fcde2c3cece4eb14171237d913`, including inline questions, saved answers, partial submission and Bots.
- Six extracted 8090 planning skills are bundled under `deploy/docker/skills`.

Ink-owned build repositories are reserved for platform builds. Publish external
service images into the dedicated `leeroo-jaz` repository and deploy through the
Leeroo Ink API. The connected Deployink MCP points at Ink Cloud, a separate
installation.

- Web appearance defaults include `showModelIcons: false`; explicit browser preferences override defaults.
- Live Codex defaults: built-in `openai-api-key`, `gpt-6-sol`, `medium`, saved and read back on 2026-10-01. The deployed image seeds the same values once; later user settings are preserved.
- Replacement OpenAI key installed on 2026-10-01 in the service environment and saved Codex API-key profile. Provider validation returns 200; a real GPT-6 Sol / medium reply returned `LEEROO_READY`. Verification sessions were archived.
- Core capability fix `c39a7033` is isolated on `jaz/leeroo-codex-config-fix`, not merged or deployed.
