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
# codebase-memory-mcp: 代码知识图谱 MCP（agent 指令要求检索优先；postinstall 从 GitHub Releases 下载原生二进制，镜像 +~300MB）
ARG OPENSPEC_VERSION=latest
ARG DBX_MCP_VERSION=latest
ARG CBM_MCP_VERSION=0.11.0
RUN npm install -g pnpm@${PNPM_VERSION} @deepseek-ai/dsh@${DSH_VERSION} \
  @fission-ai/openspec@${OPENSPEC_VERSION} @dbx-app/mcp-server@${DBX_MCP_VERSION} \
  codebase-memory-mcp@${CBM_MCP_VERSION} \
  @deepseek-ai/dsh-browser-use@${DSH_VERSION} \
  @deepseek-ai/dsh-experimental-browser-use-chrome-devtools-mcp@${DSH_VERSION} && \
  dsh --version && openspec --version && codebase-memory-mcp --version

USER docker
WORKDIR /home/docker

ENV HOME=/home/docker

COPY --chown=docker:docker entrypoint.sh /home/docker/entrypoint.sh
RUN chmod +x /home/docker/entrypoint.sh

# 容器唯一对外口：dsh-pocket 代理（本机/局域网/公网入口统一由此进出，含 PIN 认证）
# dsh web 自身固定监听 127.0.0.1:3080（官方安全限制），不经此口暴露
EXPOSE 3081

ENTRYPOINT ["/home/docker/entrypoint.sh"]
CMD ["dsh", "web", "--no-open"]
