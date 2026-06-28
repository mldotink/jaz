#!/usr/bin/env bash
# Start the stock Jaz backend on loopback and Caddy as the single public
# listener. Same auth.json seeding as jaz-backend (JAZ_ROOT_KEY on first boot).
# If either process exits, the script exits so the orchestrator restarts the box.
set -euo pipefail

JAZ_ROOT="${JAZ_ROOT:-/var/lib/jaz}"
AUTH_FILE="${JAZ_ROOT}/auth.json"

mkdir -p "${JAZ_ROOT}/workspaces/default"

if [ -n "${JAZ_ROOT_KEY:-}" ] && [ ! -f "${AUTH_FILE}" ]; then
	( umask 077; printf '{\n  "api_key": "%s"\n}\n' "${JAZ_ROOT_KEY}" > "${AUTH_FILE}" )
fi

# Backend stays on loopback; Caddy fronts it on ${PORT}. --public-url makes the
# backend's issued client URLs match the public origin.
/opt/jaz/bin/jaz --addr "127.0.0.1:5299" --public-url "${JAZ_PUBLIC_URL:-}" &
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &

wait -n
