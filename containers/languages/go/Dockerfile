ARG GO_VERSION
FROM golang:${GO_VERSION}

ARG USER_ID
RUN useradd docker -u ${USER_ID} -g root -m

USER docker
