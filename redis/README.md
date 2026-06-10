# Redis

Redis 7 缓存容器，挂载自定义配置文件，支持数据持久化和日志记录。

## 镜像

- **基础镜像**: `redis:7.4.5`（通过 `REDIS_VERSION` 环境变量控制）
- **构建产物**: `docker-redis:7.4.5`

## 端口

| 端口 | 用途                                         |
| ---- | -------------------------------------------- |
| 6379 | Redis 默认端口，映射到宿主机 `${REDIS_PORT}` |

## 挂载

| 宿主机路径                | 容器路径                          | 说明               |
| ------------------------- | --------------------------------- | ------------------ |
| `redis/redis.conf`        | `/usr/local/etc/redis/redis.conf` | Redis 配置文件     |
| `${REDIS_HOST_DATA_PATH}` | `/data`                           | RDB/AOF 数据持久化 |
| `redis/log/`              | `/var/log/redis/`                 | 日志文件           |
| `redis/log/redis.log`     | `/var/log/redis/redis-server.log` | 服务器日志         |

## 使用方式

```bash
# 启动
docker compose up -d redis

# 连接
./run.sh redis "redis-cli"

# 带密码连接（如配置了 requirepass）
./run.sh redis "redis-cli -a <password>"

# 进入容器
docker exec -it redis bash

# 宿主机连接
redis-cli -h 127.0.0.1
```

## 配置说明

配置文件 `redis/redis.conf` 为完整 Redis 配置（约 62KB），包含所有 Redis 7 配置项。可根据需要调整：

- 持久化策略（RDB 快照 / AOF 日志）
- 内存管理（maxmemory 限制、淘汰策略）
- 网络绑定（bind 地址）
- 密码认证（requirepass）
