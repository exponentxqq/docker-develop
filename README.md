# docker-develop

个人开发环境的 Docker 编排，13 个容器覆盖数据库、缓存、Web 代理、语言运行时和辅助工具。

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
├── README.md                    # 本文件（汇总）
├── docker-compose.yml           # 入口：networks + include
├── compose/
│   ├── services.yml             # 基础服务
│   ├── languages.yml            # 语言运行时
│   └── tools.yml                # 辅助工具
├── bin/                         # 宿主机快捷命令
├── cache/                       # 包管理器缓存目录
├── common/                      # 共享配置（.zshrc, .vimrc）
├── .env                         # 环境变量（需自行创建）
├── .env-example                 # 环境变量模板
├── run.sh                       # 容器命令执行脚本
├── build.sh                     # 镜像构建脚本（带代理）
└── containers/                  # 容器目录（按 compose 分类）
    ├── services/                # 基础服务
    ├── languages/               # 语言运行时
    └── tools/                   # 辅助工具
```

## 服务一览

### 基础服务

| 服务                           | 容器名   | 镜像           | 说明                           |
| ------------------------------ | -------- | -------------- | ------------------------------ |
| [mysql](containers/services/mysql/README.md)       | mysql    | `mysql:5.7`    | MySQL 5.7 + mycli + XtraBackup |
| [postgres](containers/services/postgres/README.md) | postgres | `postgres:13`  | PostgreSQL 13                  |
| [redis](containers/services/redis/README.md)       | redis    | `redis:7`      | Redis 7 + 持久化               |
| [mongo](containers/services/mongo/README.md)       | mongo    | `mongo:latest` | MongoDB + 认证                 |
| [nginx](containers/services/nginx/README.md)       | nginx    | `nginx:1.28`   | 反向代理 + HTTPS               |

### 语言运行时

| 服务                       | 容器名 | 镜像              | 说明                         |
| -------------------------- | ------ | ----------------- | ---------------------------- |
| [node](containers/languages/node/README.md)     | node   | `debian:bookworm` | Node.js + Volta 多版本管理   |
| [fpm](containers/languages/fpm/README.md)       | fpm    | `php:7.2-fpm`     | PHP-FPM + Composer + Xdebug  |
| [java](containers/languages/java/README.md)     | java   | `openjdk:11`      | JDK 11 + Maven/Gradle/Flyway |
| [go](containers/languages/go/README.md)         | go     | `golang:latest`   | Go 工具链                    |
| [python](containers/languages/python/README.md) | python | `miniconda3`      | Conda + UV 双工具链          |
| [rust](containers/languages/rust/README.md)     | rust   | `rust:1.83`       | Rust + Cargo + gdb           |

### 辅助工具

| 服务                             | 容器名    | 镜像           | 说明              |
| -------------------------------- | --------- | -------------- | ----------------- |
| [kubectl](containers/tools/kubectl/README.md)     | kubectl   | `ubuntu:22.04` | Kubernetes CLI    |
| [litellm](containers/tools/litellm/README.md)     | litellm   | `litellm:main` | LLM API 网关      |

> 每个服务的详细说明、配置参数、使用方式见对应目录下的 `README.md`。

## run.sh 用法

```bash
./run.sh <服务名> "<命令>"
./run.sh node "pnpm install"
./run.sh mysql "mysql -uroot -p -e 'SHOW DATABASES'"
```

`run.sh` 自动检测容器是否运行 → 未运行则启动 → 映射工作目录后执行命令。同时自动传递 tab 补全所需的 `COMP_*` 环境变量。

## Compose 文件拆分

通过 `include` 指令按服务类型拆分为 4 个文件：

| 文件                    | 服务                                 |
| ----------------------- | ------------------------------------ |
| `docker-compose.yml`    | networks + include                   |
| `compose/services.yml`  | mysql, postgres, redis, mongo, nginx |
| `compose/languages.yml` | fpm, node, java, go, python, rust    |
| `compose/tools.yml`     | kubectl, litellm                |

所有文件由入口 `docker-compose.yml` 通过 `include` 自动合并，`run.sh`、`build.sh` 无需任何改动。

## 常用命令

```bash
# 构建镜像
docker compose build <服务名>
./build.sh node          # 构建时使用代理（HTTP_PROXY）

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
