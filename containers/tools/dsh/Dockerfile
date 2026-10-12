# DeepSeek Harness (dsh) 工具容器
# 官方要求 Node ^22.19.0 || >=24.0.0（24.0/24.1 有已知静默退出回归，故取 >=24.2）
ARG NODE_VERSION=24.21.0
FROM node:${NODE_VERSION}-slim

# python3/make/g++: node-pty 等原生模块编译
# procps: 提供 pkill，供 bin/ 包装脚本的清理逻辑使用
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  curl wget ca-certificates git python3 make g++ procps \
  chromium chromium-sandbox fonts-noto-cjk \
  && rm -rf /var/lib/apt/lists/*

# docker CLI + buildx/compose 插件（静态二进制，pin 版本与宿主对齐；dsh 会话经 socket 操作宿主 daemon）
# buildx：会话内 docker compose build 走 BuildKit（无插件时 compose 回退内嵌 classic builder，
# 不支持 COPY --chmod 等 BuildKit 语法）；默认 builder 为 docker driver，复用宿主 daemon 内建
# BuildKit，与宿主构建共享层缓存。docker buildx version 兼作装完自校验（失败破层缓存重试）
ARG DOCKER_CLI_VERSION=29.9.0
ARG DOCKER_COMPOSE_VERSION=v5.6.0
ARG DOCKER_BUILDX_VERSION=v0.38.0
RUN curl -fsSL "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_CLI_VERSION}.tgz" \
      | tar -xz -C /usr/local/bin --strip-components=1 docker/docker && \
    mkdir -p /usr/local/lib/docker/cli-plugins && \
    curl -fsSL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64" \
      -o /usr/local/lib/docker/cli-plugins/docker-compose && \
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose && \
    curl -fsSL "https://github.com/docker/buildx/releases/download/${DOCKER_BUILDX_VERSION}/buildx-${DOCKER_BUILDX_VERSION}.linux-amd64" \
      -o /usr/local/lib/docker/cli-plugins/docker-buildx && \
    chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx && \
    docker --version && docker compose version && docker buildx version

# dsh 会话专用 java 包装（/usr/local/bin 已在 PATH，无需 entrypoint 改动）：
# 转发 java 容器。宿主侧刻意不提供 bin/java——nvim jdtls 的 JDK home 推导
# （command -v java）与 conform 的 google-java-format 都依赖宿主 PATH 的裸 java。
COPY --chmod=755 java-wrapper /usr/local/bin/java

ARG HOST_UID HOST_GID HOST_USER
# node 官方镜像预置 UID 1000 的 node 用户，与宿主 UID 冲突，先移除（与 languages/node 一致）
RUN userdel -r node 2>/dev/null || true; \
  groupadd -g ${HOST_GID} docker && \
  useradd -m -u ${HOST_UID} -g ${HOST_GID} -s /bin/bash docker

# 全局安装需要写 /usr/local，必须在切换用户前以 root 执行
ARG DSH_VERSION=latest
ARG PNPM_VERSION=10
# openspec: spec 驱动开发 CLI（agent/skills 中的 openspec-* skill 依赖）
# @dbx-app/mcp-server: dbx MCP server（dsh-mcp-client 经 npx 启动，预装免下载）
# codebase-memory-mcp: 不在镜像内安装，二进制来自宿主 npm 全局包目录（compose 只读挂载到 /usr/local/lib/cbm-host）
ARG OPENSPEC_VERSION=latest
ARG DBX_MCP_VERSION=latest
# 回归护栏：npm 对 optionalDependencies 偶发静默跳过（拉取瞬时失败不报错、install 仍 exit 0，
# 当前运行容器即因此缺原生包——mcp-server 启动即退，dsh 侧报 server is disconnected）。
# npm 11 全局安装不提升（hoist）optional 依赖，原生包位于包内嵌套路径。装完校验其落盘；
# 并入同一 RUN 以便失败时破掉本层缓存、下次构建自动重试安装
# （镜像与上方 docker CLI 同为 x86_64 专用，平台写死）。
RUN npm install -g pnpm@${PNPM_VERSION} @deepseek-ai/dsh@${DSH_VERSION} \
  @fission-ai/openspec@${OPENSPEC_VERSION} @dbx-app/mcp-server@${DBX_MCP_VERSION} \
  @deepseek-ai/dsh-browser-use@${DSH_VERSION} \
  @deepseek-ai/dsh-experimental-browser-use-chrome-devtools-mcp@${DSH_VERSION} && \
  dsh --version && openspec --version && \
  test -f /usr/local/lib/node_modules/@dbx-app/mcp-server/node_modules/@dbx-app/mcp-linux-x64-gnu/bin/dbx-mcp

# codebase-memory-mcp：软链指向运行时挂载的宿主包目录（直指静态二进制，不经 npm wrapper、不依赖系统 node）
RUN ln -s /usr/local/lib/cbm-host/bin/codebase-memory-mcp /usr/local/bin/codebase-memory-mcp

# ~/.cache 预建为 docker 属主：compose bind mount 的目标父目录若缺失，
# docker 会以 root 自动创建，导致容器内 git hook（codebase-reindex 写日志/pending）无权写入
RUN install -d -o docker -g docker /home/docker/.cache

USER docker
WORKDIR /home/docker

ENV HOME=/home/docker

COPY --chown=docker:docker entrypoint.sh /home/docker/entrypoint.sh
RUN chmod +x /home/docker/entrypoint.sh

# 容器唯一对外口：dsh-pocket 代理（本机/局域网/公网入口统一由此进出，含 PIN 认证）
# dsh web 自身固定监听 127.0.0.1:3080（官方安全限制），不经此口暴露
EXPOSE 3081

ENTRYPOINT ["/home/docker/entrypoint.sh"]
# CMD 必须用绝对路径：entrypoint 末尾把包装脚本目录前置进 PATH 后，裸名 `dsh` 会解析到
# <项目>/docker/bin/dsh 包装脚本——PID1 变成 bash 包装、经 docker exec 回到本容器重建进程树，
# 而 docker exec 不继承 entrypoint 环境（PATH 注入失效），包装脚本也不转发 SIGTERM
# （docker stop 等 10s 后被 SIGKILL）。绝对路径直指容器内真 dsh，环境随进程正常继承。
CMD ["/usr/local/bin/dsh", "web", "--no-open"]
