ARG NODE_VERSION
FROM node:${NODE_VERSION}

RUN npm install -g typescript

ARG USER_ID
RUN useradd docker -u ${USER_ID} -g root -m