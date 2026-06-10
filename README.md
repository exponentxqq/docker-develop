# docker-develop

开发环境的 Docker 编排，17 个服务覆盖数据库、缓存、Web 服务器和各语言运行时。

## 快速开始

```bash
# 1. 复制并编辑环境变量
cp .env-example .env
vim .env  # 修改 HOST_PROJECT_PATH、DOCKER_HOST_IP 等

# 2. 构建并启动服务
cd ~/develop/docker
docker compose up -d mysql          # 单个服务
docker compose up -d mysql nginx    # 多个服务

# 3. 进入容器执行命令
./run.sh node "pnpm dev"
./run.sh mysql "mysql -uroot -p"

# 4. 使用 bin 快捷脚本（需将 bin/ 加入 PATH）
pnpm add react                     # 等价于 ./run.sh node "pnpm add react"
```

## 目录结构

```
docker/
├── docker-compose.yml          # 入口：networks + include
├── compose/
│   ├── services.yml            # mysql, postgres, redis, mongo, nginx
│   ├── languages.yml           # fpm, node, java, go, python, rust
│   └── tools.yml               # workspace, kubectl, lsp, litellm
├── bin/                        # 宿主机快捷命令
├── cache/                      # 包管理器缓存
├── .env                        # 环境变量（需自行创建）
├── .env-example                # 环境变量模板
├── run.sh                      # 容器命令执行脚本
├── build.sh                    # 镜像构建脚本（带代理）
└── */                          # 各服务 Dockerfile 和配置
```

## 服务一览

| 服务      | 分类      | 容器名    | 说明                        |
| --------- | --------- | --------- | --------------------------- |
| mysql     | services  | mysql     | MySQL 5.7                   |
| postgres  | services  | postgres  | PostgreSQL 13               |
| redis     | services  | redis     | Redis 7                     |
| mongo     | services  | mongo     | MongoDB                     |
| nginx     | services  | nginx     | Nginx 反向代理              |
| node      | languages | node      | Node.js（Volta 多版本管理） |
| fpm       | languages | fpm       | PHP 7.2                     |
| java      | languages | java      | JDK 11 + Maven/Gradle       |
| go        | languages | go        | Go                          |
| python    | languages | python    | Python（Conda）             |
| rust      | languages | rust      | Rust                        |
| workspace | tools     | workspace | Ubuntu 通用工作区           |
| kubectl   | tools     | kubectl   | Kubernetes CLI              |
| lsp       | tools     | lsp       | Neovim/Claude Code LSP 服务 |
| litellm   | tools     | litellm   | LLM API 网关                |

## run.sh 用法

```bash
./run.sh <服务名> "<命令>"
./run.sh node "pnpm install"
./run.sh mysql "mysql -uroot -p -e 'SHOW DATABASES'"
./run.sh workspace "ls -la"
```

`run.sh` 会自动：检测容器是否运行 → 未运行则启动 → 映射工作目录后执行命令。

## Compose 文件拆分

通过 `include` 指令按服务类型拆分为 4 个文件：

| 文件                    | 服务                                 |
| ----------------------- | ------------------------------------ |
| `docker-compose.yml`    | networks + include                   |
| `compose/services.yml`  | 基础服务（数据库 + 缓存 + 反向代理） |
| `compose/languages.yml` | 语言运行时                           |
| `compose/tools.yml`     | 辅助工具                             |

所有文件由入口 `docker-compose.yml` 通过 `include` 自动合并，`run.sh`、`build.sh` 无需任何改动。

## Node 服务

Node 服务基于 `debian:bookworm-slim` + **Volta**，一个容器覆盖所有版本：

```bash
# 日常开发
run.sh node "pnpm dev"

# 版本管理
volta list              # 查看已安装版本
volta install node@20   # 安装其他版本
```

项目在 `package.json` 中通过 `volta` 字段锁定版本：

```json
{
  "volta": {
    "node": "16.20.2",
    "pnpm": "8.15.9"
  }
}
```

`cd` 进项目目录后 Volta 自动切换，无需手动操作。

## 常用命令

```bash
# 构建镜像
docker compose build <服务名>
./build.sh node          # 构建时使用代理

# 启动/停止
docker compose up -d <服务名>
docker compose stop <服务名>

# 查看状态
docker compose ps

# 进入容器
docker exec -it node /bin/bash

# 清理
docker compose down
```

## 环境要求

- Docker
- Docker Compose v2.20+（需要 `include` 指令支持）
