#!/usr/bin/env bash
set -euo pipefail

if [ "${JAZ_SEED_INK_MCP:-true}" = "false" ]; then
	exit 0
fi

node <<'JS'
const crypto = require('node:crypto')
const fs = require('node:fs')
const path = require('node:path')

const root = process.env.JAZ_ROOT || '/var/lib/jaz'
const port = process.env.JAZ_BACKEND_PORT || process.env.PORT || '5299'
const authFile = `${root}/auth.json`
const seedAuthFile = `${root}/.state/ink-mcp-seed-auth.json`
const baseURL = `http://127.0.0.1:${port}`
const desired = {
  name: process.env.JAZ_INK_MCP_NAME || 'Ink',
  url: process.env.JAZ_INK_MCP_URL || 'https://mcp.ml.ink/',
  enabled: true,
  bearer_token_env_var: process.env.JAZ_INK_MCP_BEARER_TOKEN_ENV_VAR || 'INK_API_KEY',
}

class RequestError extends Error {
  constructor(method, requestPath, status, body) {
    super(`${method} ${requestPath} failed: ${status} ${body}`)
    this.status = status
  }
}

let cachedSeedToken = ''

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

function writeJSONFile(file, value) {
  fs.mkdirSync(path.dirname(file), { recursive: true, mode: 0o700 })
  fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`, { mode: 0o600 })
}

function readSeedAuth() {
  try {
    const auth = JSON.parse(fs.readFileSync(seedAuthFile, 'utf8'))
    return typeof auth.token === 'string' && auth.token ? auth : null
  } catch {
    return null
  }
}

function base64URL(buf) {
  return buf.toString('base64').replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/g, '')
}

function newSeedDeviceInput() {
  const publicKey = crypto.randomBytes(32)
  return {
    name: 'Jaz defaults seed',
    kind: 'cli',
    platform: 'container',
    device_id: crypto.createHash('sha256').update(publicKey).digest('hex'),
    public_key: base64URL(publicKey),
  }
}

async function requestWithToken(path, init = {}, token) {
  const method = init.method || 'GET'
  const res = await fetch(`${baseURL}${path}`, {
    ...init,
    headers: {
      Authorization: `Bearer ${token}`,
      ...(init.body ? { 'Content-Type': 'application/json' } : {}),
      ...(init.headers || {}),
    },
  })
  if (!res.ok) {
    throw new RequestError(method, path, res.status, await res.text())
  }
  return res.json()
}

async function registerSeedDevice() {
  const result = await requestWithToken('/v1/devices/register', {
    method: 'POST',
    body: JSON.stringify(newSeedDeviceInput()),
  }, rootKey())
  if (!result.token) {
    throw new Error('Jaz did not return a seed device token')
  }
  writeJSONFile(seedAuthFile, { token: result.token, device_id: result.device && result.device.id })
  cachedSeedToken = result.token
  return result.token
}

async function seedToken() {
  if (cachedSeedToken) return cachedSeedToken
  const auth = readSeedAuth()
  if (auth) {
    cachedSeedToken = auth.token
    return cachedSeedToken
  }
  return registerSeedDevice()
}

async function request(path, init = {}) {
  try {
    return await requestWithToken(path, init, await seedToken())
  } catch (err) {
    if (!(err instanceof RequestError) || err.status !== 401) throw err
    cachedSeedToken = ''
    try {
      fs.rmSync(seedAuthFile)
    } catch {
    }
    return requestWithToken(path, init, await registerSeedDevice())
  }
}

function sameServer(server) {
  return server.name === desired.name &&
    server.url === desired.url &&
    server.enabled === true &&
    server.bearer_token_env_var === desired.bearer_token_env_var
}

async function seedDefaults() {
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

async function main() {
  await waitForBackend()
  await seedDefaults()
}

main().catch((err) => {
  console.error(err.message)
  process.exit(1)
})
JS
