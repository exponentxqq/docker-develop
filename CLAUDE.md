# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```bash
# All commands run from the repo root (~/develop/docker/)

# Build images (add build.sh for proxy: `./build.sh <service>`)
docker compose build <service>

# Start a service
docker compose up -d <service>

# Execute commands inside a running container
./run.sh <service> "<command>"
./run.sh node "pnpm dev"
./run.sh mysql "mysql -uroot -p"

# Validate compose config
docker compose config --no-path-resolution
```

## Architecture

Multi-service Docker dev environment, 16 services on a single `backend` bridge network (subnet `172.20.0.0/16`). Each service has a static IP.

**Compose split via `include` (Compose v2.20+):**

```
docker-compose.yml          → networks + include directives
compose/services.yml        → mysql, postgres, redis, mongo, nginx
compose/languages.yml       → fpm, node, java, go, python, rust
compose/tools.yml           → workspace, kubectl, lsp, litellm
```

All paths in sub-files are relative to the **including file** (`docker-compose.yml`), not the sub-file itself. Paths use `../` prefix to reach the repo root (e.g., `context: ../node`, `../cache/pnpm-cache`).

## Environment Variables

All configuration driven by `.env` (copy from `.env-example`). Key variables:

- `HOST_PROJECT_PATH` / `CONTAINER_PROJECT_PATH` — project directory mapping
- `DOCKER_HOST_IP` — host IP for xdebug/extra_hosts
- `USER_ID` — should match host user id for file permissions
- Service-specific variables: `MYSQL_VERSION`, `PHP_VERSION`, `JDK_VERSION`, etc.

## run.sh

Wrapper that ensures a container is running, then `docker exec`s into it. Automatically maps `$HOST_PROJECT_PATH` to `$CONTAINER_PROJECT_PATH` so working directory is transparent.

TTY detection (`[ -t 0 ] && [ -t 1 ]`) prevents docker `-t` flag from being added when stdout is piped (avoids stdout/stderr merging in completion contexts).

## Node Service (Volta)

Base image: `debian:bookworm-slim`. Volta manages node/npm/pnpm/yarn versions per project via `package.json` `volta` field. Default Node version set by `NODE_VERSION` env var, pre-installed at build time along with `pnpm@latest`.

**Named volume `volta-cache`** (not bind mount) preserves pre-installed tools across container rebuilds. Named volumes copy image data on first creation; bind mounts would overwrite with empty host directory.

## bin/ Scripts

Shell scripts in `bin/` wrap `run.sh` for direct invocation from host:
`bin/pnpm` → `run.sh node pnpm "$@"`

Add `~/develop/docker/bin` to host `$PATH` to use them anywhere.

## Build with Proxy

`build.sh` passes `--build-arg HTTP_PROXY` / `HTTPS_PROXY` for builds behind a proxy.
