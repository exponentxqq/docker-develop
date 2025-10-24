ARG UBUNTU_VERSION
FROM ubuntu:${UBUNTU_VERSION}

RUN apt-get update && apt-get install -y curl

ARG KUBECTL_VERSION
RUN curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"
RUN curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
RUN echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl

USER root
