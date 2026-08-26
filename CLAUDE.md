# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```bash
# All commands run from the repo root (~/develop/docker/)

# Build images
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

Multi-service Docker dev environment, 17 services on a single `backend` bridge network. Services are addressed by container name (no static IPs).

**Compose split via `include` (Compose v2.20+):**

```
docker-compose.yml          → networks + include directives
compose/services.yml        → mysql, postgres, redis, rabbitmq, mongo, nginx, rocketmq-namesrv, rocketmq-broker
compose/languages.yml       → fpm, node, java, go, python, rust
compose/tools.yml           → kubectl, dbx, hermes
```

**Container directories** are organized under `containers/` mirroring the compose split:
- `containers/services/` — mysql, postgres, redis, rabbitmq, mongo, nginx, rocketmq
- `containers/languages/` — fpm, node, java, go, python, rust
- `containers/tools/` — kubectl, dbx, hermes

All paths in sub-files are relative to the **including file** (`docker-compose.yml`), not the sub-file itself. Paths use `../` prefix to reach the repo root (e.g., `context: ../containers/languages/node`, `../cache/pnpm-cache`).

## Environment Variables

All configuration driven by `.env` (copy from `.env-example`). Key variables:

- `HOST_PROJECT_PATH` / `CONTAINER_PROJECT_PATH` — project directory mapping
- `DOCKER_HOST_IP` — host IP for xdebug/extra_hosts
- `HOST_UID` / `HOST_GID` / `HOST_USER` — should match host user id/group for file permissions
- Service-specific variables: `MYSQL_VERSION`, `PHP_VERSION`, `MISE_VERSION`, etc.

## run.sh

Wrapper that ensures a container is running, then `docker exec`s into it. Host and container project paths are identical (`HOST_PROJECT_PATH` == `CONTAINER_PROJECT_PATH`), so it simply `cd`s to the current working directory inside the container and runs the command via `bash --login` (loads profile PATH).

TTY detection (`[ -t 0 ] && [ -t 1 ]`) prevents docker `-t` flag from being added when stdout is piped (avoids stdout/stderr merging in completion contexts). Completion-related env vars (`COMP_LINE` etc.) are forwarded into the container.

## Java Service (mise)

Base image: `debian:bookworm-slim`. [mise](https://mise.jdx.dev/) manages JDK/Maven/Gradle versions per project via `.mise.toml` at the project root; unversioned projects fall back to the image global defaults (java 11 + maven 3.6.3 + gradle 6.0.1).

```toml
# 项目根目录 .mise.toml
[tools]
java = "17"
maven = "3.9"
gradle = "8"
```

Install new versions with `./run.sh java "mise install java@21"` — persisted in the `mise-cache` named volume across rebuilds. Ports: 8081-8089 (web apps, 8080 reserved for host), 5750 (JDWP remote debug via `JAVA_OPTS`).

## Node Service (Volta)

Base image: `debian:bookworm-slim`. Volta manages node/npm/pnpm/yarn versions per project via `package.json` `volta` field. Default Node version set by `NODE_VERSION` env var, pre-installed at build time along with `pnpm@latest` and `yarn`. `VOLTA_VERSION` is pinned and verified at build; image tag is `docker-node:${VOLTA_VERSION}`.

**Named volume `volta-cache`** (not bind mount) preserves pre-installed tools across container rebuilds. Named volumes copy image data on first creation; bind mounts would overwrite with empty host directory.

node/go containers mount the entire host home directory (`${HOST_HOME}:${HOST_HOME}`) so LSP servers (gopls, rust-analyzer) can resolve file URIs.

## bin/ Scripts

Shell scripts in `bin/` wrap `run.sh` for direct invocation from host:
`bin/pnpm` → `run.sh node pnpm "$@"`

Add `~/develop/docker/bin` to host `$PATH` to use them anywhere.

## Build with Proxy

`docker compose build --build-arg HTTP_PROXY=... --build-arg HTTPS_PROXY=... <service>` for builds behind a proxy.
