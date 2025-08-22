ARG NODE_VERSION
FROM node:${NODE_VERSION}

ARG PNPM_VERSION
RUN chown -R node:node /home/node && \
    npm install -g typescript pnpm@${PNPM_VERSION}

ARG USER_ID
USER node

RUN npm config set cache /home/node/.npm && \
    mkdir /home/node/.pnpm && \
    pnpm config set store-dir /home/node/.pnpm
