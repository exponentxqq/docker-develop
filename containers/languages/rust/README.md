# Rust

Rust 开发容器，基于 Debian Bookworm Slim，通过 rustup 安装工具链，集成常用开发工具和数据库客户端库。

## 镜像

- **基础镜像**: `debian:bookworm-slim`
- **Rust 安装**: 通过 rustup 安装，版本由 `.env` 中 `RUST_VERSION` 控制
- **构建产物**: `docker-rust:${RUST_VERSION}`
- **用户**: 容器用户（`HOST_USER`）与宿主机保持一致，通过 identity mount 消除路径差异

## 工具链

| 组件            | stable      | nightly     |
| --------------- | :---------: | :---------: |
| rustc / cargo   | ✅          | ✅           |
| rust-analyzer   | ✅          | ✅           |
| clippy          | ✅          | —           |
| rustfmt         | ✅          | —           |
| rust-src        | ✅          | ✅           |

## 预装工具

| 工具                        | 用途                                |
| --------------------------- | ----------------------------------- |
| build-essential, pkg-config | C/C++ 编译（Rust 依赖的 C 库）      |
| libssl-dev                  | OpenSSL（TLS/HTTPS）                |
| libpq-dev                   | PostgreSQL 客户端库（diesel, sqlx） |
| default-libmysqlclient-dev  | MySQL 客户端库                      |
| gdb, gdbserver              | 调试器及远程调试                    |
| git, curl, wget, zsh, vim   | 开发工具                            |

## 端口

| 端口 | 用途               |
| ---- | ------------------ |
| 3001 | 默认 Web 应用端口  |
| 9999 | 备用端口（调试等） |

## 挂载

| 宿主机路径                           | 容器路径                            | 说明                                     |
| ------------------------------------ | ----------------------------------- | ---------------------------------------- |
| `${HOST_PROJECT_PATH}`               | `${CONTAINER_PROJECT_PATH}`         | 项目代码                                 |
| `${HOST_PROJECT_PATH}`               | `${HOST_PROJECT_PATH}`              | 项目代码（identity mount，路径一致）     |
| `/home/${HOST_USER}/.cargo`          | `/home/${HOST_USER}/.cargo`         | Cargo 缓存（identity mount，路径一致）   |
| `/usr/local/rustup`                  | `/usr/local/rustup`                 | Rust 工具链（identity mount，路径一致）  |
| `common/.zshrc`                      | `/home/${HOST_USER}/.zshrc`         | Zsh 配置                                 |
| `common/.vimrc`                      | `/home/${HOST_USER}/.vimrc`         | Vim 配置                                 |

> **identity mount**: 宿主机与容器使用相同路径。rust-analyzer 返回的文件路径（std 源码、依赖 crate 源码）在宿主机可直接访问，无需路径翻译。

## 环境变量

| 变量                 | 值                              | 说明                                      |
| -------------------- | ------------------------------- | ----------------------------------------- |
| `RUSTUP_HOME`        | `/usr/local/rustup`             | 全局 toolchain 路径                       |
| `CARGO_HOME`         | `/home/${HOST_USER}/.cargo`     | Cargo 安装路径                            |
| `RUSTC_BOOTSTRAP`    | `1`                             | 允许 stable cargo 解析 std 的 Cargo.toml |
| `DEEPSEEK_API_KEY`   | （从 `.env` 继承）              | AI API Key（如项目需要）                  |

## Neovim LSP 配置

rust-analyzer 通过 `docker exec` 包装脚本运行，配置位于 `~/develop/docker/bin/rust-analyzer`：

```bash
#!/bin/bash
exec docker exec -i rust rust-analyzer "$@"
```

Neovim 插件配置见 `~/.config/nvim/lua/plugins/lsp-rust.lua`。

## 使用方式

```bash
# 启动
docker compose up -d rust

# 编译和运行
./run.sh rust "cargo build"
./run.sh rust "cargo run"
./run.sh rust "cargo test"

# 代码检查
./run.sh rust "cargo clippy"
./run.sh rust "cargo fmt"

# 依赖管理
./run.sh rust "cargo update"
./run.sh rust "cargo add some-crate"

# 调试（使用 gdb）
./run.sh rust "rust-gdb target/debug/myapp"

# 交互式 shell
docker exec -it rust bash
```
