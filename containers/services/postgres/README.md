# PostgreSQL

PostgreSQL 13 数据库容器，轻量封装官方镜像，数据持久化 + 日志管理。

## 镜像

- **基础镜像**: `postgres:13.22`（通过 `POSTGRES_VERSION` 环境变量控制）
- **构建产物**: `docker-postgres:13.22`

## 端口

| 端口 | 用途                                                 |
| ---- | ---------------------------------------------------- |
| 5432 | PostgreSQL 默认端口，映射到宿主机 `${POSTGRES_PORT}` |

## 挂载

| 宿主机路径                   | 容器路径              | 说明       |
| ---------------------------- | --------------------- | ---------- |
| `${POSTGRES_HOST_DATA_PATH}` | `/var/lib/postgresql` | 数据持久化 |
| `postgres/log`               | `/var/log/postgresql` | 日志输出   |

## 环境变量

| 变量                | 默认值     | 说明                        |
| ------------------- | ---------- | --------------------------- |
| `POSTGRES_USER`     | `root`     | 超级用户                    |
| `POSTGRES_PASSWORD` | `123456`   | 密码                        |
| `POSTGRES_DB`       | `postgres` | 默认数据库                  |
| `TZ`                | `UTC`      | 时区（继承全局 `TIMEZONE`） |

## 使用方式

```bash
# 启动
docker compose up -d postgres

# 进入 psql
./run.sh postgres "psql -U root"

# 执行 SQL
./run.sh postgres "psql -U root -c 'SELECT version()'"

# 进入容器
docker exec -it postgres bash

# 宿主机连接
psql -h 127.0.0.1 -U root -d postgres
```

## 日志管理

日志限制：单文件最大 10MB，最多保留 3 个文件（在 `compose/services.yml` 中配置）。
