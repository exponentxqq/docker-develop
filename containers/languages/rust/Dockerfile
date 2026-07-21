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
ARG USER_ID
ARG HOST_USER
RUN useradd -m -u ${USER_ID} -g root ${HOST_USER}

# rustup 环境变量（全局安装路径）
ENV RUSTUP_HOME=/usr/local/rustup \
  CARGO_HOME=/usr/local/cargo \
  PATH=/usr/local/cargo/bin:${PATH}

# 通过 rustup 安装 Rust（root 执行）
# - 默认 toolchain 为 RUST_VERSION（stable）
# - 额外预装 nightly 和常用组件
# - chown 确保 docker 用户可以同步 toolchain 更新
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
  | sh -s -- -y --default-toolchain ${RUST_VERSION} --profile default \
  && rustup component add rust-analyzer clippy rustfmt \
  && rustup toolchain install nightly \
  && rustup component add rust-src rust-analyzer --toolchain nightly \
  && rustup update \
  && chown -R ${HOST_USER}:root /usr/local/rustup


USER ${HOST_USER}

# .cargo 通过 identity mount 与宿主机共享；RUSTUP_HOME 指向全局 toolchain
ENV RUSTUP_HOME=/usr/local/rustup \
  CARGO_HOME=/home/${HOST_USER}/.cargo \
  PATH=/home/${HOST_USER}/.cargo/bin:/usr/local/cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
