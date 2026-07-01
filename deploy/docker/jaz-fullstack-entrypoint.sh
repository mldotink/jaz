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

export PORT="${PORT:-8080}"
export JAZ_BACKEND_PORT="${JAZ_BACKEND_PORT:-5299}"

( PORT="${JAZ_BACKEND_PORT}" /usr/local/bin/jaz-backend-entrypoint.sh ) &
backend_pid=$!

caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
caddy_pid=$!

shutdown() {
	kill "${backend_pid}" "${caddy_pid}" 2>/dev/null || true
}
trap shutdown INT TERM

set +e
wait -n "${backend_pid}" "${caddy_pid}"
status=$?
shutdown
wait "${backend_pid}" "${caddy_pid}" 2>/dev/null
exit "${status}"
