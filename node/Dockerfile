ARG NODE_VERSION
FROM node:${NODE_VERSION}
USER root
# RUN npm install -g typescript pnpm

ARG USER_ID
#RUN gpasswd -a node root
RUN id && su && useradd docker -u ${USER_ID} -g root -m
USER node
RUN npm config set cache /home/docker/.npm
