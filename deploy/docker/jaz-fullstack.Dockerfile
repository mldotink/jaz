# syntax=docker/dockerfile:1.7
#
# jaz-fullstack: backend + web app in ONE single-origin image, with NO backend
# code changes. Caddy fronts the container — it serves the built SPA and reverse-
# proxies the API surface to the stock backend on loopback, so the app and API
# share an origin (no CORS, no #server connect step). The backend is the same
# published release binary as jaz-backend; only the web build is pinned to
# VITE_JAZ_API_URL=origin so the app talks to its own origin.
#
# Like jaz-web, this NEEDS the Jaz frontend source: build with a Jaz checkout as
# context (copy deploy/docker/ into it, or run build.sh from there).
#
#   docker buildx build -f deploy/docker/jaz-fullstack.Dockerfile \
#     --build-arg JAZ_VERSION=v0.0.69 -t augustinast/testing:jaz-fullstack --push .
#
# Build context is the Jaz repo root (for frontend/ and deploy/docker/* files).

FROM oven/bun:1.3.5 AS web
WORKDIR /src/frontend
# electron is a dev dep of the desktop app; skip its big binary download.
ENV ELECTRON_SKIP_BINARY_DOWNLOAD=1
COPY frontend/package.json frontend/bun.lock ./
RUN bun install --frozen-lockfile
COPY frontend/ ./
# Same-origin build: the app calls the backend at its own origin, no baked URL.
RUN VITE_JAZ_API_URL=origin bun run build:web

FROM node:22-bookworm-slim AS runtime
# linux/amd64 -> amd64, linux/arm64 -> arm64 (set by buildx).
ARG TARGETARCH
# Release tag to install, or "latest".
ARG JAZ_VERSION=latest

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl git tini \
 && rm -rf /var/lib/apt/lists/*

# Static Caddy binary from the official image (serves the SPA + proxies the API).
COPY --from=caddy:2 /usr/bin/caddy /usr/bin/caddy

# Backend Unix user. Agents run as this user and see HOME=/var/lib/jaz.
RUN useradd --system --uid 10001 --home-dir /var/lib/jaz --shell /usr/sbin/nologin jaz \
 && install -d -o jaz  -g jaz  -m 755 /var/lib/jaz /var/lib/jaz/workspaces/default \
 && install -d -o root -g root -m 755 /opt/jaz/bin /etc/jaz /etc/caddy

# Stock backend release binary — identical install to jaz-backend, no changes.
RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
      amd64|arm64) arch="${TARGETARCH:-amd64}";; \
      *) echo "unsupported architecture: ${TARGETARCH}"; exit 1;; \
    esac; \
    if [ "${JAZ_VERSION}" = "latest" ]; then \
      base="https://github.com/gluonfield/jaz/releases/latest/download"; \
    else \
      base="https://github.com/gluonfield/jaz/releases/download/${JAZ_VERSION}"; \
    fi; \
    asset="jaz-backend-linux-${arch}.tar.gz"; \
    cd /tmp; \
    curl -fsSLO "${base}/${asset}"; \
    curl -fsSLO "${base}/${asset}.sha256"; \
    test "$(awk '{print $1}' "${asset}.sha256")" = "$(sha256sum "${asset}" | awk '{print $1}')"; \
    tar -xzf "${asset}"; \
    install -o root -g root -m 755 jaz /opt/jaz/bin/jaz; \
    rm -f "${asset}" "${asset}.sha256" jaz

COPY --from=web /src/frontend/dist-web         /srv
COPY deploy/docker/application.yaml            /etc/jaz/application.yaml
COPY deploy/docker/jaz-fullstack.Caddyfile     /etc/caddy/Caddyfile
COPY deploy/docker/jaz-fullstack-entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV APPLICATION_CONFIG=/etc/jaz/application.yaml \
    HOME=/var/lib/jaz \
    JAZ_LOG=info \
    PORT=8080
VOLUME ["/var/lib/jaz"]
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -fsS "http://127.0.0.1:${PORT}/health" || exit 1

ENTRYPOINT ["/usr/bin/tini", "-g", "--", "/usr/local/bin/entrypoint.sh"]
