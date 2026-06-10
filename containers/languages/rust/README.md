# Rust

Rust 开发容器，基于官方 Rust 镜像，集成常用开发工具和数据库客户端库。

## 镜像

- **基础镜像**: `rust:1.83`（通过 `RUST_VERSION` 环境变量控制）
- **构建产物**: `docker-rust:1.83`

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

| 宿主机路径             | 容器路径                    | 说明                                  |
| ---------------------- | --------------------------- | ------------------------------------- |
| `${HOST_PROJECT_PATH}` | `${CONTAINER_PROJECT_PATH}` | 项目代码                              |
| `rust/cargo-cache`     | `/home/docker/.cargo`       | Cargo 缓存（registry, git checkouts） |
| `common/.zshrc`        | `/home/docker/.zshrc`       | Zsh 配置                              |
| `common/.vimrc`        | `/home/docker/.vimrc`       | Vim 配置                              |

## 环境变量

| 变量               | 值                    | 说明                     |
| ------------------ | --------------------- | ------------------------ |
| `CARGO_HOME`       | `/home/docker/.cargo` | Cargo 安装路径           |
| `DEEPSEEK_API_KEY` | （从 `.env` 继承）    | AI API Key（如项目需要） |

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
