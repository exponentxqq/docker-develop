FROM debian:bookworm-slim

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  curl ca-certificates \
  python3 build-essential \
  libgtk-3-0 libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb \
  libgbm1 libdrm2 libxcb-dri3-0 libx11-xcb1 libxcomposite1 libxcursor1 libxdamage1 \
  libxfixes3 libxi6 libxrandr2 libxrender1 libxshmfence1 libxkbcommon0 \
  libegl1 libgl1 libgles2 fonts-liberation \
  libappindicator3-1 xdg-utils wget x11-apps dbus-x11 \
  git \
  && rm -rf /var/lib/apt/lists/*

ARG HOST_UID HOST_GID HOST_USER
RUN groupadd -g ${HOST_GID} docker && \
  useradd -m -u ${HOST_UID} -g ${HOST_GID} -s /bin/bash docker

# login shell 下 /etc/profile 会重置 PATH，此脚本确保 volta bin 始终在 PATH 中
RUN echo 'export PATH="/home/docker/.volta/bin:$PATH"' > /etc/profile.d/volta.sh

USER docker
WORKDIR /home/docker

ENV VOLTA_HOME=/home/docker/.volta
ENV PATH=$VOLTA_HOME/bin:$PATH

ARG NODE_VERSION=22
ARG VOLTA_VERSION=2.0.2
# 安装脚本下载失败时退出码仍为 0（脚本 bug），volta --version 作兜底校验
RUN set -eux; \
  curl -fsSL https://get.volta.sh | bash -s -- --version ${VOLTA_VERSION}; \
  volta --version; \
  volta install node@${NODE_VERSION} pnpm@latest yarn@1.22.22
