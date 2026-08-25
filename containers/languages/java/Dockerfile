ARG MISE_VERSION=latest
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
  cmake build-essential ant git curl wget ca-certificates \
  && wget -qO- https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/6.4.2/flyway-commandline-6.4.2-linux-x64.tar.gz | tar xvz \
  && ln -s `pwd`/flyway-6.4.2/flyway /usr/local/bin && chmod +x /usr/local/bin/flyway \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

ARG HOST_UID HOST_GID HOST_USER
RUN groupadd -g ${HOST_GID} docker && \
  useradd -m -u ${HOST_UID} -g ${HOST_GID} -s /bin/bash docker

# login shell 下 /etc/profile 会重置 PATH，此脚本确保 mise 本体与 shims 始终在 PATH 中
RUN echo 'export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"' > /etc/profile.d/mise.sh

USER docker
WORKDIR /home/docker

ENV PATH="/home/docker/.local/bin:$PATH"

ARG MISE_VERSION=2026.8.12
# mise.run 脚本在当前版本时走 mise.jdx.dev 的默认 URL（404 bug），
# 直接下载 GitHub release tarball 更可控；版本号由 MISE_VERSION 控制
RUN set -eux; \
  curl -fsSL -o /tmp/mise.tar.gz "https://github.com/jdx/mise/releases/download/v${MISE_VERSION}/mise-v${MISE_VERSION}-linux-x64.tar.gz"; \
  mkdir -p /home/docker/.local/bin; \
  tar -xzf /tmp/mise.tar.gz -C /tmp && mv /tmp/mise/bin/mise /home/docker/.local/bin/mise && chmod +x /home/docker/.local/bin/mise; \
  mise --version; \
  mise install java@11; \
  mise install java@17; \
  mise install maven@3.6.3; \
  mise install maven@3.9; \
  mise install gradle@6.0.1; \
  mise install gradle@8; \
  mise use --global java@11 maven@3.6.3 gradle@6.0.1; \
  mise reshim; \
  ls $HOME/.local/share/mise/shims

# build opencv
COPY ./build.sh /opt
ARG BUILD_OPENCV=false
RUN if [ $BUILD_OPENCV = true ]; then cd /opt && git config --global http.postBuffer 524288000 && sh build.sh; fi
