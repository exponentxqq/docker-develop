# IDEA / RustRover 在 Docker 环境下开发调试 Rust

## 前置条件

- 已安装 [Rust 插件](https://plugins.jetbrains.com/plugin/8182-rust)（IntelliJ IDEA）或 [RustRover](https://www.jetbrains.com/rust/)
- 已安装 [Docker 插件](https://plugins.jetbrains.com/plugin/7724-docker)（IDEA Ultimate 自带）
- rust 容器已启动：`cd ~/develop/docker && docker compose up -d rust`

---

## 一、环境变量配置

在 `~/develop/docker/.env` 中确保：

```bash
# 项目路径（宿主机绝对路径，指向你的 Rust 项目根目录）
HOST_PROJECT_PATH=/home/xuqinqin/develop/person/os

# 容器内对应路径（一般保持 /develop）
CONTAINER_PROJECT_PATH=/develop

# 宿主机 user id，与宿主机一致以保证文件权限
USER_ID=1000
```

---

## 二、Toolchain 配置

### 方式 A：使用宿主机 Rust（推荐，简单）

在宿主机安装 Rust，IDEA 使用本地 toolchain：

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

IDEA 会自动检测。若未检测到：**Settings → Languages & Frameworks → Rust**，指定 `~/.cargo/bin` 下的 rustc。

### 方式 B：使用容器内 Rust（与运行环境一致）

1. **Settings → Languages & Frameworks → Rust**，添加 Rust toolchain
2. 选择 **Custom**，Toolchain location 填：`docker://rust`（需先配置 Docker 连接）
3. 或使用 **Remote**：通过 SSH 连接容器（需在容器内启用 sshd，较复杂）

若宿主机 Rust 版本与容器一致，可优先用方式 A，开发体验更好。

---

## 三、运行配置（Run Configuration）

### 方式 1：通过 Docker 执行

1. **Run → Edit Configurations → + → Shell Script**
2. 配置：
   - **Name:** `cargo run (Docker)`
   - **Script text:**
     ```bash
     docker compose -f /home/xuqinqin/develop/docker/docker-compose.yml run --rm rust cargo run
     ```
   - **Working directory:** `$HOST_PROJECT_PATH` 或你的项目路径

### 方式 2：使用 Cargo 配置（需宿主机有 Rust）

1. **Run → Edit Configurations → + → Cargo**
2. **Command:** `run`
3. **Working directory:** 项目根目录

若宿主机 Rust 与容器一致，用方式 2 更简单；否则用方式 1 保证环境一致。

---

## 四、远程调试配置

### 1. 在容器内启动 gdbserver

```bash
docker compose -f ~/develop/docker/docker-compose.yml exec rust bash -c "
  cd /develop && \
  cargo build && \
  gdbserver :9999 target/debug/你的程序名
"
```

或进入容器后手动执行：

```bash
docker compose exec rust zsh
cd /develop
cargo build
gdbserver :9999 target/debug/你的程序名
```

### 2. 在 IDEA 中配置 Remote Debug

1. **Run → Edit Configurations → + → Remote Debug**
2. 选择 **GDB**
3. 配置：
   - **'target remote' args:** `localhost:9999`
   - **Symbol file:** 宿主机上 `target/debug/你的程序名` 的路径（与容器内路径一致，因挂载）
   - **Path mappings（可选）：**
     - Remote: `/develop`
     - Local: `/home/xuqinqin/develop/person/os`（或你的宿主机项目路径）

4. 启动 Debug 会话，连接 gdbserver

### 3. 端口映射

确保 `docker-compose.yml` 中 rust 服务已暴露 9999 端口：

```yaml
ports:
  - "3001:3001"
  - "9999:9999"   # gdbserver
```

---

## 五、Dev Container 方案（可选）

若希望用 RustRover 的 Remote Development 直接连到容器：

1. 在项目根目录创建 `.devcontainer/devcontainer.json`：

```json
{
  "name": "Rust Dev",
  "dockerComposeFile": ["../../docker/docker-compose.yml"],
  "service": "rust",
  "workspaceFolder": "/develop",
  "customizations": {
    "vscode": {
      "extensions": ["rust-lang.rust-analyzer"]
    }
  }
}
```

2. 在 RustRover 中：**Remote Development → Create Dev Containers**，选择该 devcontainer 配置

> 注意：此方式依赖 RustRover 的 Dev Container 支持，可能需在 RustRover 中操作。

---

## 六、常见问题

### rust-analyzer 报错

- 确认项目根目录有 `Cargo.toml`
- 确认 Toolchain 配置正确（Settings → Rust）
- 可尝试 **File → Invalidate Caches → Invalidate and Restart**

### 容器内文件权限

- 确保 `USER_ID` 与宿主机 `id -u` 一致
- 容器内创建的文件应属主正确

### 调试断点不生效

- 检查 Symbol file 是否指向带 debug 信息的可执行文件（`cargo build`，不要 `cargo build --release`）
- 检查 Path mappings 是否正确
