# MySQL

MySQL 5.7 数据库容器，集成 mycli、XtraBackup 和 qpress，支持备份恢复和数据持久化。

## 镜像

- **基础镜像**: `mysql:5.7`（可通过 `MYSQL_IMAGE` / `MYSQL_VERSION` 环境变量切换）
- **构建产物**: `docker-mysql:5.7`

## 预装工具

| 工具             | 用途                                        |
| ---------------- | ------------------------------------------- |
| mycli            | 交互式 MySQL 客户端，支持语法高亮和自动补全 |
| xtrabackup (2.4) | Percona XtraBackup，在线热备份              |
| qpress           | 压缩/解压工具，用于 xtrabackup 压缩备份     |

## 端口

| 端口 | 用途                                         |
| ---- | -------------------------------------------- |
| 3306 | MySQL 默认端口，映射到宿主机 `${MYSQL_PORT}` |

## 挂载

| 宿主机路径                   | 容器路径                      | 说明                         |
| ---------------------------- | ----------------------------- | ---------------------------- |
| `${MYSQL_HOST_DATA_PATH}`    | `/var/lib/mysql`              | 数据持久化                   |
| `${MYSQL_ENTRYPOINT_INITDB}` | `/docker-entrypoint-initdb.d` | 初始化脚本（首次启动执行）   |
| `mysql/my.cnf`               | `/etc/mysql/conf.d/my.cnf`    | 自定义 MySQL 配置            |
| `${HOST_PROJECT_PATH}`       | `${CONTAINER_PROJECT_PATH}`   | 项目代码（便于导入导出 SQL） |

## 关键配置 (`my.cnf`)

```ini
character-set-server=utf8          # UTF-8 字符集
collation-server=utf8_general_ci   # 排序规则
default-time-zone='+08:00'         # 东八区
transaction_isolation=READ-COMMITTED
max_allowed_packet=500M            # 大文件导入
server_id=1918
log_bin=mysql-bin                  # 二进制日志（主从复制）
binlog_format=ROW
```

## 环境变量

| 变量                  | 默认值    | 说明             |
| --------------------- | --------- | ---------------- |
| `MYSQL_ROOT_PASSWORD` | `123456`  | root 密码        |
| `MYSQL_USER`          | `docker`  | 普通用户         |
| `MYSQL_PASSWORD`      | `123456`  | 普通用户密码     |
| `MYSQL_DATABASE`      | `default` | 自动创建的默认库 |

## 使用方式

```bash
# 启动
docker compose up -d mysql

# 交互式客户端（推荐）
./run.sh mysql "mycli -uroot -p"

# 执行 SQL
./run.sh mysql "mysql -uroot -p123456 -e 'SHOW DATABASES'"

# 进入容器
docker exec -it mysql bash

# 宿主机连接（需 mycli 已安装）
mycli -h 127.0.0.1 -u root -p123456

# 使用 bin 快捷命令（需将 bin/ 加入 PATH）
mycli -h 127.0.0.1
```

## 备份与恢复

容器内提供了 `scripts/` 目录下的辅助脚本：

```bash
# 快照备份（使用 xtrabackup）
cd /home/xuqinqin/develop/docker/mysql/scripts
./db-snapshot.sh

# 恢复备份
./db-restore.sh
```

## 初始化数据库

将 `.sql` 文件放入 `mysql/docker-entrypoint-initdb.d/` 目录，容器首次启动时自动执行。参考 `createdb.sql.example`。
