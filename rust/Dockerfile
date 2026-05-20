ARG RUST_VERSION
FROM rust:${RUST_VERSION}

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  git curl wget zsh vim \
  build-essential pkg-config \
  libssl-dev libpq-dev default-libmysqlclient-dev \
  gdb gdbserver \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

ARG USER_ID
RUN useradd -m -u ${USER_ID} -g root docker

USER docker
ENV CARGO_HOME=/home/docker/.cargo
ENV PATH=${CARGO_HOME}/bin:${PATH}
