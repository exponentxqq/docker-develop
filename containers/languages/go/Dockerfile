ARG GO_VERSION
FROM golang:${GO_VERSION}

ARG HOST_UID HOST_GID HOST_USER
RUN groupadd -g ${HOST_GID} docker && \
  useradd -m -u ${HOST_UID} -g ${HOST_GID} -s /bin/bash docker

# login shell 下 /etc/profile 会重置 PATH，此脚本确保 go 工具链在 PATH 中
RUN echo 'export PATH="/usr/local/go/bin:/go/bin:$PATH"' > /etc/profile.d/go.sh

ENV GOBIN=/usr/local/bin
# gopls 版本自适应 GO_VERSION:从新到旧尝试,GOTOOLCHAIN=local 防止自动下载新工具链
# 导致构建成功但运行时与基础镜像 go 版本不匹配
RUN set -eux; \
  unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy; \
  export GOTOOLCHAIN=local; \
  for v in latest v0.22.0 v0.20.0 v0.18.1 v0.17.1 v0.16.2 v0.15.3 v0.14.4 v0.13.2 v0.12.4 v0.11.0; do \
  if go install golang.org/x/tools/gopls@"$v"; then break; fi; \
  done; \
  gopls version

USER docker
WORKDIR /home/docker
