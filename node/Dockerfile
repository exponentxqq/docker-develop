ARG NODE_VERSION
FROM node:${NODE_VERSION}

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 build-essential \
    libgtk-3-0 libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb \
    libgbm1 libdrm2 libxcb-dri3-0 libx11-xcb1 libxcomposite1 libxcursor1 libxdamage1 \
    libxfixes3 libxi6 libxrandr2 libxrender1 libxshmfence1 libxkbcommon0 \
    libegl1 libgl1 libgles2 ca-certificates fonts-liberation \
    libappindicator3-1 xdg-utils wget x11-apps dbus-x11

ARG PNPM_VERSION
RUN npm install -g typescript pnpm@${PNPM_VERSION}

ARG USER_ID

RUN sed -i "s/node:x:1000:1000/node:x:${USER_ID}:${USER_ID}/" /etc/passwd && \
    sed -i "s/node:x:1000:/node:x:${USER_ID}:/" /etc/group && \
    chown -R ${USER_ID}:${USER_ID} /home/node && \
    chown -R ${USER_ID}:${USER_ID} /tmp

USER node

RUN npm config set cache /home/node/.npm && \
    mkdir /home/node/.pnpm && \
    pnpm config set store-dir /home/node/.pnpm && \
    mkdir /home/node/.yarn && \
    yarn config set cache-folder /home/node/.yarn

ENV PNPM_TMPDIR=/home/node/.pnpm
