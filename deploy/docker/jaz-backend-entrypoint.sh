#!/usr/bin/env bash
# Start the Jaz backend. If the deploy provides JAZ_ROOT_KEY (a template-
# generated secret), seed auth.json with it on first boot so the deployer knows
# the bootstrap key up front instead of a random one generated inside the box.
set -euo pipefail

JAZ_ROOT="${JAZ_ROOT:-/var/lib/jaz}"
AUTH_FILE="${JAZ_ROOT}/auth.json"
PORT="${PORT:-5299}"

mkdir -p "${JAZ_ROOT}/workspaces/default"

if [ -n "${JAZ_ROOT_KEY:-}" ] && [ ! -f "${AUTH_FILE}" ]; then
	( umask 077; printf '{\n  "api_key": "%s"\n}\n' "${JAZ_ROOT_KEY}" > "${AUTH_FILE}" )
fi

# --addr binds all interfaces; the host (Ink) routes to it and terminates TLS.
# --public-url makes printed/issued client URLs match the public origin; safe to
# leave empty when the platform doesn't expose the service's own URL at runtime.
/opt/jaz/bin/jaz --addr ":${PORT}" --public-url "${JAZ_PUBLIC_URL:-}" &
backend_pid=$!

shutdown() {
	kill "${backend_pid}" 2>/dev/null || true
}
trap shutdown INT TERM

if ! JAZ_BACKEND_PORT="${PORT}" /usr/local/bin/jaz-seed-defaults.sh; then
	echo "warning: failed to seed Jaz defaults" >&2
fi

wait "${backend_pid}"
