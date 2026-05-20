# ==============================================================================
# LSP Container - Multi-stage Dockerfile
# Hosts 20+ language servers for IDE-driven LSP access via:
#   docker exec -i lsp <lsp-binary> --stdio
# ==============================================================================

# ---------------------------------------------------------------------------
# Stage 1: Node.js LSP packages (pyright, vtsls, typescript-language-server, etc.)
# ---------------------------------------------------------------------------
FROM node:22-slim AS node-builder

RUN npm install -g --prefix /opt/lsp/node \
    pyright \
    basedpyright \
    @vue/language-server \
    vscode-langservers-extracted \
    yaml-language-server \
    @tailwindcss/language-server \
    @prisma/language-server \
    dockerfile-language-server-nodejs \
    @microsoft/compose-language-service \
    bash-language-server \
    typescript-language-server

# ---------------------------------------------------------------------------
# Stage 2: Eclipse JDT Language Server (Java)
# ---------------------------------------------------------------------------
FROM eclipse-temurin:21-jdk AS jdk-builder

ARG JDTLS_VERSION=1.58.0
ARG JDTLS_BUILD=202604151538

RUN mkdir -p /opt/lsp/jdtls && \
    curl -fSL "https://download.eclipse.org/jdtls/milestones/${JDTLS_VERSION}/jdt-language-server-${JDTLS_VERSION}-${JDTLS_BUILD}.tar.gz" \
    -o /tmp/jdtls.tar.gz && \
    tar xzf /tmp/jdtls.tar.gz -C /opt/lsp/jdtls --strip-components=1 && \
    rm /tmp/jdtls.tar.gz

# ---------------------------------------------------------------------------
# Stage 3: Go LSP (gopls)
# ---------------------------------------------------------------------------
FROM golang:1.26-bookworm AS go-builder

RUN go install golang.org/x/tools/gopls@latest && \
    mkdir -p /opt/lsp/go/bin && \
    cp "$(go env GOPATH)/bin/gopls" /opt/lsp/go/bin/

# ---------------------------------------------------------------------------
# Stage 4: Rust LSP (rust-analyzer) - prebuilt binary from GitHub release
# ---------------------------------------------------------------------------
FROM alpine:3.21 AS rust-builder

ARG RA_VERSION=2026-05-18

RUN apk add --no-cache curl xz && \
    mkdir -p /opt/lsp/rust/bin && \
    curl -fsSL "https://github.com/rust-lang/rust-analyzer/releases/download/${RA_VERSION}/rust-analyzer-x86_64-unknown-linux-gnu.gz" \
    | gunzip > /opt/lsp/rust/bin/rust-analyzer && \
    chmod +x /opt/lsp/rust/bin/rust-analyzer

# ---------------------------------------------------------------------------
# Stage 5: Lua LSP (lua-language-server) - prebuilt binary
# ---------------------------------------------------------------------------
FROM alpine:3.21 AS lua-builder

ARG LUA_LS_VERSION=3.13.0

RUN apk add --no-cache curl && \
    mkdir -p /opt/lsp/lua && \
    curl -fsSL "https://github.com/LuaLS/lua-language-server/releases/download/${LUA_LS_VERSION}/lua-language-server-${LUA_LS_VERSION}-linux-x64.tar.gz" \
    | tar xz -C /opt/lsp/lua && \
    chmod +x /opt/lsp/lua/bin/lua-language-server

# ---------------------------------------------------------------------------
# Stage 6: Ruff LSP (Python linter) - prebuilt binary
# ---------------------------------------------------------------------------
FROM alpine:3.21 AS ruff-builder

ARG RUFF_VERSION=0.12.11

RUN apk add --no-cache curl && \
    mkdir -p /opt/lsp/ruff/bin && \
    curl -fsSL "https://github.com/astral-sh/ruff/releases/download/${RUFF_VERSION}/ruff-x86_64-unknown-linux-gnu.tar.gz" \
    | tar xz -C /opt/lsp/ruff/bin --strip-components=1 && \
    chmod +x /opt/lsp/ruff/bin/ruff

# ---------------------------------------------------------------------------
# Stage 7: Marksman LSP (Markdown) - prebuilt binary
# ---------------------------------------------------------------------------
FROM alpine:3.21 AS marksman-builder

ARG MARKSMAN_VERSION=2026-02-08

RUN apk add --no-cache curl && \
    mkdir -p /opt/lsp/marksman/bin && \
    curl -fsSL "https://github.com/artempyanykh/marksman/releases/download/${MARKSMAN_VERSION}/marksman-linux-x64" \
    -o /opt/lsp/marksman/bin/marksman && \
    chmod +x /opt/lsp/marksman/bin/marksman

# ==============================================================================
# Final stage: runtime image with all language servers
# ==============================================================================
FROM ubuntu:22.04

# ---- Install system prerequisites ----
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        libicu70 && \
    rm -rf /var/lib/apt/lists/*

# ---- Install Node.js 22 runtime (NodeSource) ----
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" \
    > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# ---- Copy LSP binaries from builder stages ----
COPY --from=node-builder /opt/lsp/node /opt/lsp/node
COPY --from=jdk-builder /opt/lsp/jdtls /opt/lsp/jdtls
COPY --from=jdk-builder /opt/java/openjdk /opt/java/openjdk
COPY --from=go-builder  /opt/lsp/go   /opt/lsp/go
COPY --from=rust-builder /opt/lsp/rust /opt/lsp/rust
COPY --from=lua-builder /opt/lsp/lua  /opt/lsp/lua
COPY --from=ruff-builder /opt/lsp/ruff /opt/lsp/ruff
COPY --from=marksman-builder /opt/lsp/marksman /opt/lsp/marksman

# ---- Environment ----
ENV JAVA_HOME="/opt/java/openjdk"
ENV PATH="/opt/lsp/node/bin:/opt/lsp/lua/bin:/opt/lsp/go/bin:/opt/lsp/rust/bin:/opt/lsp/jdtls:/opt/lsp/ruff/bin:/opt/lsp/marksman/bin:${JAVA_HOME}/bin:${PATH}"

# ---- Security: run as non-root ----
USER 1000:1000

# ---- Health check: verify Node.js is functional ----
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD node -e "process.exit(0)"

# ---- Keep container alive indefinitely ----
CMD ["sleep", "infinity"]
