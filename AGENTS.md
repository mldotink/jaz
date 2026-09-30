# Leeroo Ink deployment

- Ink runs in Leeroo’s AWS account `221082199974`, EKS cluster `uniforge-ink-eks` in `us-east-1`.
- Kubernetes context: `uniforge-aws`; AWS profile: `majid-ink`.
- Ink API: `https://api.apps.uniforge.leeroo.com/graphql`.
- Workspace: `august`; project: `default`.
- Service: `jaz-mast-v5` (`RFTiTTRs9ixGzwQPPSGzkn`).
- Endpoint: `https://jaz-mast-v5.ink.apps.uniforge.leeroo.com` (Leeroo organisation SSO).
- Data volume: `/var/lib/jaz`, existing 25 GiB volume retained.
- Image repository: `221082199974.dkr.ecr.us-east-1.amazonaws.com/leeroo-jaz`.
- Deployed image digest: `sha256:6285bb57d48f702268a35b3332b3204d0a740946f494a299dbe85df388a925d5`, tag `c4d8197`.
- Jaz source: `fc6dfb83a820b1fcde2c3cece4eb14171237d913`, including inline questions, saved answers, partial submission and Bots.
- Six extracted 8090 planning skills are bundled under `deploy/docker/skills`.

Ink-owned build repositories are reserved for platform builds. Publish external
service images into the dedicated `leeroo-jaz` repository and deploy through the
Leeroo Ink API. The connected Deployink MCP points at Ink Cloud, a separate
installation.
