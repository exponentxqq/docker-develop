ARG NODE_VERSION
FROM node:${NODE_VERSION}

USER root

ARG PNPM_VERSION
RUN npm install -g typescript pnpm@${PNPM_VERSION}

ARG USER_ID

RUN sed -i "s/node:x:1000:1000/node:x:${USER_ID}:${USER_ID}/" /etc/passwd && \
    sed -i "s/node:x:1000:/node:x:${USER_ID}:/" /etc/group && \
    chown -R ${USER_ID}:${USER_ID} /home/node && \
    chown -R ${USER_ID}:${USER_ID} /tmp

USER node

RUN mkdir -p /home/node/.pnpm && mkdir -p /home/node/.pnpm-store && \
    npm config set cache /home/node/.npm && \
    pnpm config set store-dir /home/node/.pnpm-store

ENV PNPM_TMPDIR=/home/node/.pnpm
