ARG NODE_VERSION
FROM node:${NODE_VERSION}

RUN npm install -g typescript pnpm

ARG USER_ID
RUN gpasswd -a node root

