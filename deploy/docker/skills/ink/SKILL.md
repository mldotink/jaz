---
name: ink
description: Deploy and manage cloud services on Ink (ml.ink): create projects, deploy services, deploy templates (databases, caches), manage DNS and custom domains, configure workspaces, and monitor deployments. Use this skill whenever the user mentions Ink, ml.ink, deployments, services, databases, templates, or cloud infrastructure on Ink, even if they don't say "Ink" explicitly.
allowed-tools: Bash(ink:*), Bash(which:*), Bash(command:*), Bash(npm:*), Bash(npx:*), Bash(brew:*), Bash(git:*), Write
---

# Use Ink

[Ink](https://ml.ink) is a cloud platform designed for AI agents to deploy and manage services autonomously. It makes deployments simple enough that fully autonomous agents can handle the entire lifecycle: create, deploy, monitor, and scale services without human intervention.

## Preflight

Before any operation, verify the CLI is installed and authenticated:

```bash
command -v ink
ink whoami --json
```

If the CLI is missing, install it:

```bash
npm install -g @mldotink/cli
brew install mldotink/tap/ink
```

If not authenticated, run `ink login`.

## Configuration

Ink CLI resolves context in this order, highest priority first:

1. CLI flags: `--api-key`, `--workspace`, `--project`
2. Environment: `INK_API_KEY`
3. Local config: `.ink` file in current directory
4. Global config: `~/.config/ink/config`

Use `ink whoami --json` to check current auth and inspect configured workspace/project. Treat that config as a hint, not proof it is valid: before deploying, run a scoped read such as `ink projects list --workspace <workspace> --json` or `ink services --workspace <workspace> --project <project> --json`. Prefer explicit `--workspace` and `--project` flags in automation when the target is known. Use `--json` on any command for machine-readable output.

## Git

Ink supports two git providers. Use `ink whoami` to see which are available.

### Ink Internal Git

Zero setup, works for everyone. No GitHub account needed.

```bash
ink repos create my-app
git remote add ink <url>
git push ink main
```

### GitHub

Requires GitHub OAuth and GitHub App connected at https://ml.ink.

```bash
ink deploy my-app --repo username/repo-name --host github --port 3000
```

Both git providers trigger automatic redeployment on push. After pushing code, poll `ink status <name>` to track progress.

## Secrets

Use `ink secrets` to manage env vars on running services. Changes are merged server-side and trigger an automatic redeploy.

For sensitive values, use `ink secrets import` to avoid leaking to shell history:

```bash
cat > .env.secrets <<EOF
DATABASE_URL=libsql://my-db-myworkspace.turso.io
DATABASE_AUTH_TOKEN=eyJhbG...
API_KEY=sk_live_xxx
EOF
ink secrets import my-app --file .env.secrets
rm .env.secrets
```

For non-sensitive values, `ink secrets set` is fine:

```bash
ink secrets set my-app NODE_ENV=production LOG_LEVEL=info
```

For initial deploy, use `--env-file` to pass secrets:

```bash
ink deploy my-app --repo my-app --port 3000 --env-file .env
```

Use `--env` only for non-sensitive values like `NODE_ENV=production`.

## Common Operations

```bash
ink services
ink status my-app
ink logs my-app
ink logs my-app --build
ink deploy my-app --repo my-app --port 3000
ink redeploy my-app
ink redeploy my-app --memory 1Gi --vcpu 1
ink delete my-app

ink template
ink template info postgres
ink template deploy postgres --name my-pg

ink secrets set my-app KEY=value
ink secrets import my-app --file .env
ink secrets list my-app
ink secrets unset my-app KEY
ink secrets delete my-app KEY1 KEY2

ink domains add my-app app.example.com
ink domains remove my-app app.example.com

ink dns zones
ink dns records example.com
ink dns add example.com --name sub --type A --content 1.2.3.4
ink dns delete example.com <record-id>

ink repos create my-app
ink repos token my-app

ink projects list
ink workspaces
```

## Templates

Templates deploy pre-configured stacks. Always preview before deploying to see required variables:

```bash
ink template
ink template info postgres --json
ink template deploy postgres --name my-pg --json
```

Pass template variables with `--var KEY=VALUE`:

```bash
ink template deploy postgres --name my-pg --var db_name=myapp --var storage_gi=20
```

## Deployment Flows

### Service

```bash
ink repos create my-app
git remote add ink <gitRemote_from_output>
git push ink main
ink deploy my-app --repo my-app --port 3000
ink status my-app
```

### Full-stack app

```bash
ink repos create my-api
git remote add ink <url>
git push ink main
ink deploy my-api --repo my-api --port 8080
ink status my-api

ink repos create my-frontend
git remote add ink-frontend <url>
git push ink-frontend main
ink deploy my-frontend --repo my-frontend --port 3000 \
  --env VITE_API_URL=<backend-url-from-ink-status>
```

### Database-backed app

```bash
ink template info postgres --json
ink template deploy postgres --name my-pg --json
ink deploy my-app --repo my-app --port 3000
```

Wire credentials with `ink secrets import`.

### Static site or SPA

For static files already present in the repo, use the `static` buildpack:

```bash
ink repos create my-site
git remote add ink <url>
git push ink main
ink deploy my-site --repo my-site --buildpack static
```

For prebuilt static files in a subdirectory:

```bash
ink deploy my-site --repo my-site --buildpack static --publish-dir dist
```

For frontend apps that need Ink to run a build first, leave the buildpack as railpack and specify the build output directory:

```bash
ink deploy my-site --repo my-site --publish-dir dist
```

### Monorepo

```bash
ink repos create my-monorepo
git remote add ink <url>
git push ink main

ink deploy mono-api --repo my-monorepo --root-dir backend --port 8080
ink deploy mono-web --repo my-monorepo --root-dir frontend --publish-dir dist \
  --env VITE_API_URL=<backend-url-from-ink-status>
```

## Guidelines

- Start with `ink whoami --json`.
- Validate context before deploying with `ink projects list --workspace <workspace> --json` or `ink services --workspace <workspace> --project <project> --json`.
- Check `ink services` before deploying to see if a service already exists.
- Use `ink deploy` for new services and `ink redeploy` for existing services.
- Pushing code auto-redeploys; after `git push`, poll `ink status`.
- Use `--json` when parsing results.
- Use `ink secrets import` for sensitive values.
- Use `ink secrets set` only for non-sensitive vars.
- Never use `ink redeploy --env` to update vars because it replaces all vars.
- Never hardcode or guess secret values.
- Show the service URL returned by `ink deploy`, `ink status`, or `ink services`.
- Zone delegation must be set up at https://ml.ink/dns before using `ink domains add`.
- After creating repos, services, or templates, record workspace, project, service names, and endpoints in the project's `CLAUDE.md` or `AGENTS.md`.
