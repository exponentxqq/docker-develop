ARG RUST_VERSION

FROM debian:bookworm-slim

# 重新声明 ARG 使其在后续 RUN 中可用
ARG RUST_VERSION

# 系统依赖（与原镜像保持一致）
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  git curl wget zsh vim \
  build-essential pkg-config \
  ca-certificates \
  libssl-dev libpq-dev default-libmysqlclient-dev libevdev-dev \
  gdb gdbserver \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# 先创建用户（后续需要 chown）
ARG HOST_UID HOST_GID HOST_USER
RUN groupadd -g ${HOST_GID} docker && \
  useradd -m -u ${HOST_UID} -g ${HOST_GID} -s /bin/bash docker

# rustup 环境变量（全局安装路径）
ENV RUSTUP_HOME=/usr/local/rustup \
  CARGO_HOME=/usr/local/cargo \
  PATH=/usr/local/cargo/bin:${PATH}

# 通过 rustup 安装 Rust（root 执行）
# - 默认 toolchain 为 RUST_VERSION（stable）
# - 额外预装 nightly 和常用组件
RUN set -eux; \
  curl --proto '=https' --tlsv1.2 -sSf --retry 5 --retry-delay 2 --retry-all-errors -o /tmp/rustup-init.sh https://sh.rustup.rs; \
  sh /tmp/rustup-init.sh -y --default-toolchain ${RUST_VERSION} --profile default; \
  rustup component add rust-analyzer clippy rustfmt; \
  rustup toolchain install nightly; \
  rustup component add rust-src rust-analyzer --toolchain nightly; \
  chown -R docker:root /usr/local/rustup

# login shell 下 /etc/profile 会重置 PATH，此脚本确保 cargo 工具链在 PATH 中
RUN echo 'export PATH="$HOME/.cargo/bin:/usr/local/cargo/bin:$PATH"' > /etc/profile.d/rust.sh


USER docker
WORKDIR /home/docker

# .cargo 挂载 cache 目录隔离缓存；RUSTUP_HOME 指向全局 toolchain
ENV RUSTUP_HOME=/usr/local/rustup \
  CARGO_HOME=/home/docker/.cargo \
  PATH=/home/docker/.cargo/bin:/usr/local/cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
