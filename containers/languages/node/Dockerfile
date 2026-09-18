FROM ubuntu:26.04

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  curl ca-certificates git \
  python3 build-essential \
  libgtk-3-0t64 libnotify-dev libnss3 libxss1 libasound2t64 libxtst6 xauth xvfb \
  libgbm1 libdrm2 libxcb-dri3-0 libx11-xcb1 libxcomposite1 libxcursor1 libxdamage1 \
  libxfixes3 libxi6 libxrandr2 libxrender1 libxshmfence1 libxkbcommon0 \
  libegl1 libgl1 libgles2 fonts-liberation \
  xdg-utils wget x11-apps dbus-x11 \
  && rm -rf /var/lib/apt/lists/* \
  && git --version

ARG HOST_UID HOST_GID HOST_USER
# Ubuntu 基础镜像预置 UID 1000 的 ubuntu 用户，与宿主 UID 冲突，先移除
RUN userdel -r ubuntu 2>/dev/null || true; \
  groupdel ubuntu 2>/dev/null || true; \
  groupadd -g ${HOST_GID} docker && \
  useradd -m -u ${HOST_UID} -g ${HOST_GID} -s /bin/bash docker

# login shell 下 /etc/profile 会重置 PATH，此脚本确保 volta bin 始终在 PATH 中
RUN echo 'export PATH="/home/docker/.volta/bin:$PATH"' > /etc/profile.d/volta.sh

USER docker
WORKDIR /home/docker

ENV VOLTA_HOME=/home/docker/.volta
ENV PATH=$VOLTA_HOME/bin:$PATH

ARG NODE_VERSION=22
ARG VOLTA_VERSION=2.0.2
RUN set -eux; \
  curl -fsSL https://get.volta.sh | bash -s -- --version ${VOLTA_VERSION}; \
  volta --version; \
  volta install node@${NODE_VERSION} pnpm@latest yarn@1.22.22

ARG OCR_VERSION=1.12.4
RUN volta install @alibaba-group/open-code-review@${OCR_VERSION}
