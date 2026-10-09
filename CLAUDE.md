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
compose/tools.yml           → kubectl, dbx, hermes, dsh, cloudflared
```

**Container directories** are organized under `containers/` mirroring the compose split:
- `containers/services/` — mysql, postgres, redis, rabbitmq, mongo, nginx, rocketmq
- `containers/languages/` — fpm, node, java, go, python, rust
- `containers/tools/` — kubectl, dbx, hermes, dsh

All paths in sub-files are relative to the **including file** (`docker-compose.yml`), not the sub-file itself. Paths use `../` prefix to reach the repo root (e.g., `context: ../containers/languages/node`, `../cache/pnpm-cache`).

## Environment Variables

All configuration driven by `.env` (copy from `.env-example`). Key variables:

- `HOST_PROJECT_PATH` — project directory (identity mount: same path on host and in containers)
- `DOCKER_HOST_IP` — host IP for xdebug/extra_hosts
- `HOST_UID` / `HOST_GID` / `HOST_USER` — should match host user id/group for file permissions
- Service-specific variables: `MYSQL_VERSION`, `PHP_VERSION`, `JAVA_UBUNTU_VERSION`, etc.

## run.sh

Wrapper that ensures a container is running, then `docker exec`s into it. Host and container project paths are identical, so it simply `cd`s to the current working directory inside the container and runs the command via `bash --login` (loads profile PATH).

TTY detection (`[ -t 0 ] && [ -t 1 ]`) prevents docker `-t` flag from being added when stdout is piped (avoids stdout/stderr merging in completion contexts). Completion-related env vars (`COMP_LINE` etc.) are forwarded into the container.

## Java Service (ubuntu)

Base image: `ubuntu:26.04`. apt 安装 openjdk 11/17/21（默认 17，`update-alternatives`）与 maven；gradle 由项目 wrapper（`./gradlew`）提供。版本自适应：gradle `java.toolchains` 自动探测 `/usr/lib/jvm/*`；maven 项目用 `./mvnw`。Ports: 8080-8089 (web apps; dev profile default 8080), 6666 (management)。

## Node Service (Volta)

Base image: `debian:bookworm-slim`. Volta manages node/npm/pnpm/yarn versions per project via `package.json` `volta` field. Default Node version set by `NODE_VERSION` env var, pre-installed at build time along with `pnpm@latest` and `yarn`. `VOLTA_VERSION` is pinned and verified at build; image tag is `docker-node:${VOLTA_VERSION}`.

**Named volume `volta-cache`** (not bind mount) preserves pre-installed tools across container rebuilds. Named volumes copy image data on first creation; bind mounts would overwrite with empty host directory.

node/go containers mount the entire host home directory (`${HOST_HOME}:${HOST_HOME}`) so LSP servers (gopls, rust-analyzer) can resolve file URIs.

## dsh Container

dsh（AI 开发工具）容器已接入 docker：挂载宿主 socket（`group_add` 注入 `.env` 的 `DOCKER_GID`）并烘入 docker CLI/compose 插件（`DSH_DOCKER_*` pin）；entrypoint 将 `~/develop/docker/bin` 注入会话 PATH——dsh 会话内命令与宿主同构（同一套包装脚本操作语言/服务容器）。

- `bin/{pnpm,npm,yarn}` 含 cwd 守卫：在 dsh 数据根（`/home/docker/.dsh` 下）语境自动本地执行——转投 node 容器会因该目录在 node 容器不可见（`run.sh` 的 cd 静默跳过）而把依赖装到错误位置
- pnpm store 三端共享 `/home/xuqinqin/.local/share/pnpm/store`（宿主包装 / node 容器 / dsh 容器）；dsh 侧配置在 `~/.config/pnpm/rc`（pnpm 专有文件，避免 npm 未知键警告），node 侧在 `containers/languages/node/npmrc`

## bin/ Scripts

Shell scripts in `bin/` wrap `run.sh` for direct invocation from host:
`bin/pnpm` → `run.sh node pnpm "$@"`（同构：`bin/mvn` → java 容器；Gradle 用项目自带 `./gradlew`，无包装脚本；`bin/java` 已移除——宿主裸 java 为宿主 JDK 供编辑器 LSP 使用，dsh 会话内 java 由镜像内置 `/usr/local/bin/java` 包装转发）

Add `~/develop/docker/bin` to host `$PATH` to use them anywhere.

## Build with Proxy

`docker compose build --build-arg HTTP_PROXY=... --build-arg HTTPS_PROXY=... <service>` for builds behind a proxy.
