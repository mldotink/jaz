# Jaz on Ink — container images

Docker builds for running [Jaz](https://jaz.chat) as a deployable service — on
[Ink](https://ml.ink) (via the `jaz-backend` / `jaz-full-stack` templates) or any
container host. Three images:

| Image | What it is | Build context |
| --- | --- | --- |
| **`jaz-backend`** | API-only backend: sessions, memory, tools, credentials, workspaces, coding agents (Claude, Codex, Grok), loops, git. Installs the published release binary + Node so the built-in ACP agents launch. Persistent state under `/var/lib/jaz`. | **Self-contained** — builds from this repo. |
| **`jaz-web`** | Static browser app (the SPA built from `frontend/`, served by Caddy). Connects to a backend cross-origin. | **Needs the Jaz frontend source** — build with the [Jaz repo](https://github.com/gluonfield/jaz) root as context. |
| **`jaz-fullstack`** | Backend + web app in one single-origin container, for a self-hosted VM. Caddy serves the SPA and reverse-proxies the API to the stock backend on loopback — same origin, so no CORS and no `#server` connect step. Uses the **unmodified** backend binary; the only difference from `jaz-web` is the SPA is built with `VITE_JAZ_API_URL=origin`. | **Needs the Jaz frontend source** — same as `jaz-web`. |

All build assets live under [`deploy/docker/`](deploy/docker), matching the layout
the Dockerfiles expect (the per-Dockerfile `.dockerignore` files are tuned for a
repo-root build context).

## Build & push

`build.sh` builds all images and pushes them. Override the destination repo and
the Jaz release to install:

```sh
docker login -u <user>
REPO=<namespace>/<repo> JAZ_VERSION=v0.0.69 deploy/docker/build.sh
```

- **`jaz-backend`** builds from this repo as-is — it only pulls the release binary
  (`JAZ_VERSION`, default `latest`) from the Jaz GitHub releases and adds Node.
- **`jaz-web`** and **`jaz-fullstack`** compile the SPA from `frontend/`, which is
  **not** in this repo. Build them with the Jaz source tree as context, e.g. copy
  `deploy/docker/` into a Jaz checkout (or run `build.sh` from there). `jaz-web`
  has no Jaz-version pin; `jaz-fullstack` pins the backend via `JAZ_VERSION`.

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

See [`docs/remote-backend.md`](https://github.com/gluonfield/jaz/blob/main/docs/remote-backend.md)
in the Jaz repo for the full backend/runtime model.
