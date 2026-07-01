#!/usr/bin/env bash
set -euo pipefail

if [ "${JAZ_SEED_INK_MCP:-true}" = "false" ]; then
	exit 0
fi

node <<'JS'
const fs = require('node:fs')

const root = process.env.JAZ_ROOT || '/var/lib/jaz'
const port = process.env.JAZ_BACKEND_PORT || process.env.PORT || '5299'
const authFile = `${root}/auth.json`
const baseURL = `http://127.0.0.1:${port}`
const desired = {
  name: process.env.JAZ_INK_MCP_NAME || 'Ink',
  url: process.env.JAZ_INK_MCP_URL || 'https://mcp.ml.ink/',
  enabled: true,
  bearer_token_env_var: process.env.JAZ_INK_MCP_BEARER_TOKEN_ENV_VAR || 'INK_API_KEY',
}

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms))

async function waitForBackend() {
  for (let i = 0; i < 60; i++) {
    try {
      const res = await fetch(`${baseURL}/health`)
      if (res.ok && fs.existsSync(authFile)) return
    } catch {
    }
    await sleep(500)
  }
  throw new Error(`Jaz backend did not become ready at ${baseURL}`)
}

function rootKey() {
  const raw = fs.readFileSync(authFile, 'utf8')
  const key = JSON.parse(raw).api_key
  if (!key) throw new Error(`${authFile} does not contain api_key`)
  return key
}

async function request(path, init = {}) {
  const res = await fetch(`${baseURL}${path}`, {
    ...init,
    headers: {
      Authorization: `Bearer ${rootKey()}`,
      ...(init.body ? { 'Content-Type': 'application/json' } : {}),
      ...(init.headers || {}),
    },
  })
  if (!res.ok) {
    throw new Error(`${init.method || 'GET'} ${path} failed: ${res.status} ${await res.text()}`)
  }
  return res.json()
}

function sameServer(server) {
  return server.name === desired.name &&
    server.url === desired.url &&
    server.enabled === true &&
    server.bearer_token_env_var === desired.bearer_token_env_var
}

async function main() {
  await waitForBackend()
  const list = await request('/v1/mcp/servers')
  const servers = Array.isArray(list.servers) ? list.servers : []
  const existing = servers.find((server) => server.name === desired.name || server.url === desired.url)
  if (existing && sameServer(existing)) {
    console.log('Ink MCP server already configured')
    return
  }
  if (existing) {
    await request(`/v1/mcp/servers/${encodeURIComponent(existing.id)}`, {
      method: 'PUT',
      body: JSON.stringify(desired),
    })
    console.log('Updated Ink MCP server')
    return
  }
  await request('/v1/mcp/servers', {
    method: 'POST',
    body: JSON.stringify(desired),
  })
  console.log('Created Ink MCP server')
}

main().catch((err) => {
  if (String(err.message || err).includes('device_approval_required')) {
    console.log('Jaz device approval already active; skipping default seed')
    return
  }
  console.error(err.message)
  process.exit(1)
})
JS
