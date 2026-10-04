# DeepSeek Harness (dsh)

DeepSeek 官方开源 agent harness（开发预览版），基于 Cordis「一切皆插件」架构，提供 Web UI 与 headless CLI。

## 镜像

- **基础镜像**: `node:24.21.0-slim`
- **构建产物**: `docker-dsh:0.2.0-rc.2`
- **安装方式**: npm 全局安装 `@deepseek-ai/dsh`

## 快速开始

### 启动服务

```bash
cd ~/develop/docker
docker compose build dsh
docker compose up -d dsh
```

### 首次访问

首次需要从日志中取带 token 的启动 URL 完成浏览器会话初始化：

```bash
docker compose logs dsh | grep "dsh web:"
# dsh web: http://127.0.0.1:3080/?token=...
```

在浏览器打开该 URL（地址与宿主机完全一致，端口刻意保持一致），随后在
Settings → Models 中填入 DeepSeek API Key，在目录选择器中选择工作区。

### 无浏览器 / CLI 用法

```bash
# 版本
dsh --version

# 一次性 headless 任务（默认工作区为 invoke 目录）
dsh --profile headless "跑一下单元测试"

# 插件管理
dsh plugin --profile web add <包名>
```

> `dsh` 命令来自 `bin/dsh` 包装脚本（等价 `run.sh dsh dsh ...`），需 `bin/` 在 PATH 中。

## 端口转发说明

dsh 官方出于安全考虑**拒绝绑定 0.0.0.0**（防止远程 RCE 暴露），固定监听容器内 `127.0.0.1:3080`。
容器内用 socat 将 `0.0.0.0:3081` 转发给它：

```
浏览器 → 宿主 127.0.0.1:3080 → 容器 0.0.0.0:3081 (socat) → 127.0.0.1:3080 (dsh)
```

宿主端口刻意与 dsh 实际监听端口一致（3080），保证：启动日志里的 token URL 直接可用、
浏览器 Host 头为 loopback 可通过 dsh 的 `/api` 信任栅栏、`http://127.0.0.1` 满足浏览器安全上下文。

## 配置说明

| 变量                  | 默认值       | 说明                                        |
| --------------------- | ------------ | ------------------------------------------- |
| `DSH_VERSION`         | `0.2.0-rc.2` | dsh npm 包版本                              |
| `DSH_NODE_VERSION`    | `24.21.0`    | Node 基础镜像版本（官方要求 ^22.19 或 >=24.2） |
| `DSH_WEB_PORT`        | `3080`       | Web UI 宿主机端口                           |
| `DSH_HOST_DATA_PATH`  | `/data/dsh`  | 持久化数据目录（映射容器 `~/.dsh`）         |
| `DSH_MEM_LIMIT`       | `4g`         | 内存上限                                    |

API Key、模型、会话等配置均存储在 `/data/dsh` 中，不写入 docker 仓库。

## 数据与工作区

| 宿主路径              | 容器路径              | 说明                          |
| --------------------- | --------------------- | ----------------------------- |
| `/data/dsh`           | `/home/docker/.dsh`   | 配置、会话、插件、profile     |
| `${HOST_PROJECT_PATH}` | 同路径                | 项目工作区（Web UI 中选择）   |

## 升级

```bash
vim .env  # 修改 DSH_VERSION=x.y.z-rc.n
docker compose build dsh
docker compose up -d dsh
```

dsh 处于 developer preview，官方声明会有兼容性破坏变更，升级前建议备份 `/data/dsh`。

## 注意事项

- dsh 是有文件读写与命令执行能力的 agent，仅挂载需要的工作目录。
- 局域网/远程访问需额外的 `--trusted-host` + HTTPS 反代（官方安全限制），本容器按本机
  `http://127.0.0.1:3080` 访问设计。
- 容器内 CLI（`docker exec dsh dsh ...`）与常驻 Web 服务可并存，各自独立会话。
