ARG GO_VERSION
FROM golang:${GO_VERSION}

ARG USER_ID
RUN useradd docker -u ${USER_ID} -g root -m

ENV GOBIN=/usr/local/bin
RUN go install golang.org/x/tools/gopls@latest

USER docker
