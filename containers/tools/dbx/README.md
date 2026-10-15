# DBX

多数据库 Web 客户端（MySQL / PostgreSQL / Redis / MongoDB / RocketMQ / Elasticsearch / SQLite 等统一界面），浏览器访问。

## 镜像

- **基础镜像**: `t8y2/dbx:latest`（构建产物 `docker-dbx`，构建时 `pull: true` 取最新）
- **容器名**: `dbx`

## 端口

| 端口 | 用途                                        |
| ---- | ------------------------------------------- |
| 4224 | Web UI，映射到宿主机 `${DBX_WEB_PORT}`（默认 4224） |

## 挂载

| 宿主机路径           | 容器路径     | 说明                                          |
| -------------------- | ------------ | --------------------------------------------- |
| 命名卷 `dbx-data`    | `/app/data`  | 连接配置、查询历史、密钥（SQLite `dbx.db`）   |
| `${HOST_HOME}/.ssh`  | `/root/.ssh` | SSH 隧道连接的密钥（连接公司库走跳板机时需要） |

## 环境变量

| 变量                  | 默认值 | 说明                                     |
| --------------------- | ------ | ---------------------------------------- |
| `DBX_DISABLE_PASSWORD` | `1`   | 置 1 时 Web 免登录（仅内网开发环境使用） |

## 使用方式

```bash
# 启动
docker compose up -d dbx

# 浏览器访问（宿主 IP 或本机）
open http://127.0.0.1:4224

# 进入容器（镜像内有 bash，无 curl/sqlite3，查询请走 Web UI 或宿主侧 API）
./run.sh dbx "ls /app/data"
```

## 已预置的本地连接

本地中间件连接已按容器名（`backend` 网络内可直接解析）配置好：

| 连接名                | 类型          | 地址                        |
| --------------------- | ------------- | --------------------------- |
| `localhost@mysql5.7`  | MySQL         | `mysql:3306`                |
| `localhost@postgres`  | PostgreSQL    | `postgres:5432`             |
| `localhost@redis`     | Redis         | `redis:6379`                |
| `localhost@mongo7.0`  | MongoDB       | `mongo:27017`               |
| `localhost@rocketmq`  | RocketMQ      | `rocketmq-namesrv:9876`     |
| `localhost@elastic`   | Elasticsearch | `elasticsearch:9200`（`elastic` / `123456`，无 TLS） |

> 公司环境的连接按需在 Web UI 里自行添加，不在此文档中记录。

## 连接管理（API 方式）

dbx 的 Web 前端就是调用这些 REST 接口，`DBX_DISABLE_PASSWORD=1` 时免认证，因此可以用脚本预置/校验连接（宿主机或任一在 `backend` 网络的容器内执行）：

```bash
# 列出全部连接（返回含 password 字段的完整配置）
curl -s http://dbx:4224/api/connection/list

# 校验一组连接参数能否连通（不落库；config 需为完整配置，id 必填）
curl -s -X POST http://dbx:4224/api/connection/test \
  -H 'Content-Type: application/json' \
  -d '{"config":{"id":"00000000-0000-4000-8000-000000000000","name":"probe","db_type":"elasticsearch","driver_profile":"elasticsearch","driver_label":"Elasticsearch","url_params":"sslmode=false","host":"elasticsearch","port":9200,"username":"elastic","password":"123456","database":null,"color":"","connect_timeout_secs":10,"query_timeout_secs":30,"idle_timeout_secs":60,"keepalive_interval_secs":30,"ssl":false,"sysdba":false,"connection_string":null,"external_config":null,"jdbc_driver_class":null,"jdbc_driver_paths":[],"database_info":{"productName":"Elasticsearch"}}}'
# => "Connection successful"

# 保存（upsert；省略 removedIds 表示不删除任何既有连接）
curl -s -X POST http://dbx:4224/api/connection/save \
  -H 'Content-Type: application/json' \
  -d '{"configs":[{ ...同上的完整 config... }]}'

# 健康检查（仅对已打开的连接池有效，未打开会返回 No active connection pool found）
curl -s -X POST http://dbx:4224/api/connection/check-health \
  -H 'Content-Type: application/json' -d '{"connectionId":"<连接 id>"}'
```

新增连接推荐走 API / Web UI：服务端负责把明文密码迁移到 `connection_secrets` 表并维护缓存一致性，直接写 `dbx.db` 会与运行中的 WAL 写并发冲突。

## 数据与备份

连接与历史都在命名卷 `dbx-data` 的 SQLite 里，`dbx.db` **处于 WAL 模式**：

```bash
# 备份：必须连 -wal/-shm 一起拷，否则会丢掉尚未 checkpoint 的最新写入（新建的连接就在 WAL 里）
docker compose stop dbx
docker run --rm -v dbx-data:/data -v /tmp:/backup alpine \
  sh -c 'cp /data/dbx.db* /backup/'
docker compose start dbx
```

## 注意事项

- `connection_secrets` 表中的密码是**明文**存储（随数据卷），备份文件需妥善保管
- 端口冲突时改 `.env` 的 `DBX_WEB_PORT`
- 连接配置属运行环境数据（命名卷），不入库
