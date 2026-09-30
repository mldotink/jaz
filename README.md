# Jaz on Ink — container images

Docker builds for running [Jaz](https://jaz.chat) as a deployable service — on
[Ink](https://ml.ink) (via the `jaz-backend` / `jaz-full-stack` templates) or any
container host. Four images:

| Image | What it is | Build context |
| --- | --- | --- |
| **`jaz-backend`** | API-only backend: sessions, memory, tools, credentials, workspaces, coding agents (Claude, Codex, Grok), loops, git. Installs the published release binary + Node so the built-in ACP agents launch. Persistent state under `/var/lib/jaz`. | **Self-contained** — builds from this repo. |
| **`jaz-web`** | Static browser app (the SPA built from `frontend/`, served by Caddy). Connects to a backend cross-origin. | **Needs the Jaz frontend source** — build with the [Jaz repo](https://github.com/gluonfield/jaz) root as context. |
| **`jaz-fullstack`** | Backend + web app in one single-origin container, for a self-hosted VM. Caddy serves the SPA and reverse-proxies the API to the stock backend on loopback — same origin, so no CORS and no `#server` connect step. Uses the **unmodified** backend binary; the only difference from `jaz-web` is the SPA is built with `VITE_JAZ_API_URL=origin`. | **Needs the Jaz frontend source** — same as `jaz-web`. |
| **`jaz-fullstack-custom`** | Source-built backend and web app, Leeroo defaults, Ink MCP/CLI and bundled customer-planning skills. Includes the latest question UI. | **Pinned Jaz source snapshot** plus this repository’s overlay. |

All build assets live under [`deploy/docker/`](deploy/docker), matching the layout
the Dockerfiles expect (the per-Dockerfile `.dockerignore` files are tuned for a
repo-root build context).

## Build & push

`build.sh` builds all images and pushes them. It reads the Jaz commit from
`deploy/docker/jaz-source-ref`, exports that committed source from the sibling
`../jaz` checkout into a temporary directory, and adds this repository’s Docker
overlay. Override `JAZ_SOURCE` for a different checkout or `JAZ_REF` for another
commit. The source checkout is left untouched. Override the destination repo and
the Jaz release to install:

```sh
docker login -u <user>
REPO=<namespace>/<repo> JAZ_VERSION=v0.0.69 deploy/docker/build.sh
```

- **`jaz-backend`** installs the release binary (`JAZ_VERSION`, default
  `latest`) from Jaz GitHub releases and adds Node. Its Dockerfile can also be
  built directly from this repo without a Jaz checkout.
- **`jaz-web`** and **`jaz-fullstack`** compile the SPA from the committed Jaz
  snapshot. `jaz-fullstack` installs its backend release via `JAZ_VERSION`.
- **`jaz-fullstack-custom`** builds the backend from source and always embeds
  `main.version=dev`, even when a `JAZ_VERSION` build arg is supplied. This is
  intentional: source-build images rely on the bundled `/dist/acp-adapters.json`
  instead of treating a commit SHA as a Jaz GitHub release tag.

The custom image is pinned to Jaz `fc6dfb83`, including inline questions, persisted
answer history, partial submissions and Bots. Build just that image locally:

```sh
IMAGES=jaz-fullstack-custom PUSH=false deploy/docker/build.sh
```

The image’s `org.opencontainers.image.revision` label records the exact source
commit. `PUSH=false` loads the image locally; the default `PUSH=true` publishes it.
Updating the source pin requires the selected commit to exist in `JAZ_SOURCE`.

The currently published images are `augustinast/testing:jaz-backend` and
`augustinast/testing:jaz-web`; retarget with `REPO=` once a permanent registry
namespace is chosen.

## Runtime

- **`jaz-backend`** listens on `:5299`, persists to the `/var/lib/jaz` volume, and
  seeds `auth.json` from `JAZ_ROOT_KEY` on first boot so the deployer knows the
  bootstrap key up front. Set `JAZ_PUBLIC_URL` to the public origin so issued
  client URLs match. Ink terminates TLS at its edge; the container speaks plain
  HTTP.
- **`jaz-web`** serves the SPA on `:8080` (plain HTTP, TLS at the edge). It runs no
  backend — the browser supplies a backend URL via the
  `#server=<backend>&key=<key>` fragment, so the key never reaches this host.
- **`jaz-fullstack`** serves everything on `:8080` (plain HTTP, TLS at the edge):
  Caddy proxies `/health`, `/v1/*`, `/mcp/*`, `/jazmem/*` to the backend on
  loopback and serves the SPA for the rest. Same `/var/lib/jaz` volume and
  `JAZ_ROOT_KEY` / `JAZ_PUBLIC_URL` seeding as `jaz-backend`. Because the app is
  same-origin, the browser only needs the key (`#key=<key>`), not a server URL.
  Public device pairing is disabled by default in this image; use the root key
  to connect additional clients.

The baked `application.yaml` selects a custom OpenAI-compatible provider named
`custom-openai`. It points at `https://api.openai.com/v1` as the example custom
endpoint and reads credentials from `OPENAI_API_KEY`. At startup the images also
seed an Ink MCP server (`https://mcp.ml.ink/`) that reads its bearer token from
`INK_API_KEY`. The custom full-stack web defaults also enable Open Preview for
Ink/Uniforge app URLs under `*.apps.uniforge.leeroo.com`.

```sh
docker run --rm -p 8080:8080 \
  -v jaz-data:/var/lib/jaz \
  -e JAZ_ROOT_KEY=... \
  -e OPENAI_API_KEY=... \
  -e INK_API_KEY=... \
  augustinast/testing:jaz-fullstack-custom
```

Set `JAZ_SEED_INK_MCP=false` to skip the Ink MCP seed. Advanced overrides:
`JAZ_INK_MCP_URL`, `JAZ_INK_MCP_NAME`, and
`JAZ_INK_MCP_BEARER_TOKEN_ENV_VAR`.

See [`docs/remote-backend.md`](https://github.com/gluonfield/jaz/blob/main/docs/remote-backend.md)
in the Jaz repo for the full backend/runtime model.

## Customer onboarding and planning skills

The custom image includes the six instruction sets extracted from 8090: Plan,
Requirements Writing Rules, Blueprints Writing Rules, Work Orders Writing Rules,
Extract Work Orders and Phase Planning. Their original `SKILL.md` files and source
hashes live in [`deploy/docker/skills`](deploy/docker/skills/README.md).

On startup, image skills are copied into the Jaz catalog and Codex skill directory.
Jaz installs catalog skills into supported agent profiles when they launch. This
also works on existing volumes where those skill directories are absent; existing
user skill directories are preserved. Agents can use the skills for customer
intake, migration requirements, architecture and execution planning. Local tool
and document conventions are described in the bundled README.

## Live Leeroo deployment

Updated 30 September 2026 through Ink in Leeroo’s AWS cluster:

- Service: [jaz-mast-v5](https://jaz-mast-v5.ink.apps.uniforge.leeroo.com).
- Ink API: `https://api.apps.uniforge.leeroo.com/graphql`; workspace `august`, project `default`.
- Image: `221082199974.dkr.ecr.us-east-1.amazonaws.com/leeroo-jaz@sha256:bf06b9d8225334f815f4d6372f5dcb3cb19c88006eaf4f5f4d7d72abffb49608`.
- Existing data volume and organisation SSO are retained.
- Verified: Ink status `active`, pod on the exact image digest, HTTP health/web
  app, authenticated skill catalog, all six original skill hashes and Bots API.
  The Ink MCP connection points to Uniforge and reports `connected`.
- Public browser access redirects to Leeroo sign-in, as expected for this service.

Deployment details are recorded in [AGENTS.md](AGENTS.md). This targets the
Leeroo-hosted Ink installation; the connected Deployink MCP targets Ink Cloud.

Codex is configured once at startup when this image has `OPENAI_API_KEY`: built-in
OpenAI API-key provider, GPT-6 Astra, medium effort. Subsequent choices are
preserved. The installed Codex 0.159.0 does not advertise GPT-6.1 Sol. A real
answer check reached inference but OpenAI rejected the deployed project key with
`401 invalid_api_key`; replace it before testing customer conversations.
