# docker-develop

个人开发环境的 Docker 编排，20 个容器覆盖数据库、缓存、搜索引擎、Web 代理、语言运行时和辅助工具。

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
| [mysql](containers/services/mysql/README.md)       | mysql    | `docker-mysql:5.7`    | MySQL 5.7 + mycli + XtraBackup |
| [postgres](containers/services/postgres/README.md) | postgres | `docker-postgres:13.22`  | PostgreSQL 13                  |
| [redis](containers/services/redis/README.md)       | redis    | `docker-redis:7.4.5`      | Redis 7 + 持久化               |
| rabbitmq                                           | rabbitmq | `docker-rabbitmq:3.13` | RabbitMQ 3.13 + 管理台(15672) |
| [mongo](containers/services/mongo/README.md)       | mongo    | `docker-mongo:7.0.37` | MongoDB + 认证                 |
| [elasticsearch](containers/services/elasticsearch/README.md) | elasticsearch | `docker-elasticsearch:7.17.3` | ES 7.17.3（同公司版本）+ IK 分词 + 认证 |
| [rocketmq](containers/services/rocketmq/README.md) | rocketmq-namesrv / rocketmq-broker | `docker-rocketmq:4.7.1` | RocketMQ 4.7.1（NameServer + Broker） |
| [nginx](containers/services/nginx/README.md)       | nginx    | `docker-nginx:1.28.0`   | 反向代理 + HTTPS               |

### 语言运行时

| 服务                       | 容器名 | 镜像              | 说明                         |
| -------------------------- | ------ | ----------------- | ---------------------------- |
| [node](containers/languages/node/README.md)     | node   | `docker-node:2.0.2` | Node.js + Volta 多版本管理   |
| [fpm](containers/languages/fpm/README.md)       | fpm    | `docker-fpm:8.2`     | PHP-FPM + Composer + Xdebug  |
| [java](containers/languages/java/README.md)     | java   | `docker-java:26.04`      | JDK 11/17/21 + Maven/Gradle/Flyway |
| [go](containers/languages/go/README.md)         | go     | `docker-go:1.27`   | Go 工具链                    |
| [python](containers/languages/python/README.md) | python | `docker-python:26.1.1`      | Conda + UV 双工具链          |
| [rust](containers/languages/rust/README.md)     | rust   | `docker-rust:1.95`       | Rust + Cargo + gdb           |

### 辅助工具

| 服务                             | 容器名    | 镜像           | 说明              |
| -------------------------------- | --------- | -------------- | ----------------- |
| [kubectl](containers/tools/kubectl/README.md)     | kubectl   | `docker-kubectl:1.34.1` | Kubernetes CLI    |
| [dbx](containers/tools/dbx/README.md)             | dbx       | `docker-dbx:latest` | 数据库 Web 客户端（端口 4224） |
| [hermes](containers/tools/hermes/README.md)       | hermes    | `docker-hermes:v2026.6.5` | AI 自学习代理 |
| [dsh](containers/tools/dsh/README.md)             | dsh       | `docker-dsh:0.2.0-rc.2` | DeepSeek Harness AI 代理 |
| cloudflared                                       | cloudflared | `cloudflare/cloudflared:2026.10.0` | Cloudflare 命名隧道（host 网络，回源 localhost） |

> 镜像列为 compose 实际使用的标签（构建产物 `docker-<服务>:<版本>`，版本由 `.env` 变量控制；`cloudflared` 直接用官方镜像）；各服务的基础镜像、详细说明、配置参数与使用方式见对应目录下的 `README.md`。

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
| `compose/services.yml`  | mysql, postgres, redis, rabbitmq, mongo, elasticsearch, nginx, rocketmq-namesrv, rocketmq-broker |
| `compose/languages.yml` | fpm, node, java, go, python, rust    |
| `compose/tools.yml`     | kubectl, dbx, hermes, dsh, cloudflared |

所有文件由入口 `docker-compose.yml` 通过 `include` 自动合并，`run.sh`、`build.sh` 无需任何改动。

## 共享临时目录

所有容器都 identity 挂载宿主机 `/tmp`（`/tmp:/tmp`），容器内路径与宿主一致，可用于容器之间、容器与宿主之间交换临时文件：

```bash
# 宿主（或任一分容器）写入，其他容器立即可见
echo hello > /tmp/share-test
docker exec node cat /tmp/share-test
```

- 权限沿用宿主 `/tmp` 的 `1777`（sticky）：各容器均可写，但删不掉其他用户创建的文件；
- node 容器的 X11 socket（宿主 `/tmp/.X11-unix`）随该挂载一并共享，无需单独挂载；
- 该目录受宿主 systemd-tmpfiles 定期清理，只放临时文件，勿持久化数据。

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
