# MongoDB

MongoDB 文档数据库容器，基于官方镜像，支持认证和数据持久化。

## 镜像

- **基础镜像**: `mongo:latest`（通过 `MONGO_VERSION` 环境变量控制）
- **构建产物**: `docker-mongo:latest`

## 端口

| 端口  | 用途                                           |
| ----- | ---------------------------------------------- |
| 27017 | MongoDB 默认端口，映射到宿主机 `${MONGO_PORT}` |

## 挂载

| 宿主机路径               | 容器路径                    | 说明       |
| ------------------------ | --------------------------- | ---------- |
| `${MONGO_HOST_DATA_DIR}` | `/data/db`                  | 数据持久化 |
| `${MONGO_HOST_LOG_DIR}`  | `/data/log`                 | 日志文件   |
| `${HOST_PROJECT_PATH}`   | `${CONTAINER_PROJECT_PATH}` | 项目代码   |

## 环境变量

| 变量                         | 默认值   | 说明      |
| ---------------------------- | -------- | --------- |
| `MONGO_INITDB_ROOT_USERNAME` | `root`   | root 用户 |
| `MONGO_INITDB_ROOT_PASSWORD` | `123456` | root 密码 |

## 使用方式

```bash
# 启动
docker compose up -d mongo

# 进入 mongosh
./run.sh mongo "mongosh -u root -p 123456"

# 进入容器
docker exec -it mongo bash

# 宿主机连接
mongosh mongodb://root:123456@127.0.0.1:27017
```
