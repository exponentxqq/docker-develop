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
RUN groupadd -g ${HOST_GID} ${HOST_USER} && \
    useradd -m -u ${HOST_UID} -g ${HOST_GID} -s /bin/bash ${HOST_USER}

USER ${HOST_USER}
WORKDIR /home/${HOST_USER}

RUN curl https://get.volta.sh | bash
ENV VOLTA_HOME=/home/${HOST_USER}/.volta
ENV PATH=$VOLTA_HOME/bin:$PATH

ARG NODE_VERSION=22
RUN volta install node@${NODE_VERSION} pnpm@latest
