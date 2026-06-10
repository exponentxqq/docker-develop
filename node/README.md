# Node.js

基于 Debian Bookworm + Volta 的 Node.js 开发容器，一个容器覆盖所有版本。

## 镜像

- **基础镜像**: `debian:bookworm-slim`
- **构建产物**: `docker-node:bookworm`
- **版本管理**: [Volta](https://volta.sh)（类似 nvm，但更快且支持项目级自动切换）

## 版本策略

**容器内不锁定 Node.js 版本**。每个项目通过 `package.json` 的 `volta` 字段声明自己的版本：

```json
{
  "volta": {
    "node": "16.20.2",
    "pnpm": "8.15.9"
  }
}
```

`cd` 进项目目录后 Volta 自动切换到该项目的版本，无需手动操作。

### 默认版本

构建时通过 `.env` 配置：

| 变量           | 默认值    | 说明                        |
| -------------- | --------- | --------------------------- |
| `NODE_VERSION` | `22.18.0` | 容器默认预装的 Node.js 版本 |
| `PNPM_VERSION` | `10.18.2` | 预装的 pnpm 版本            |

### 切换版本

```bash
# 查看已安装版本
volta list

# 安装其他版本
volta install node@20
volta install node@18
```

## 包管理器

预装 pnpm，通过 `node/npmrc` 配置 store 目录：

```
store-dir=/home/docker/.local/share/pnpm/store
```

支持的包管理器：pnpm（推荐）、npm、yarn。缓存目录通过挂载持久化，跨容器重建保留。

## 端口

| 端口范围  | 用途                   |
| --------- | ---------------------- |
| 8090-8099 | Web 开发服务器端口映射 |

## 挂载

| 宿主机路径                   | 容器路径                               | 说明                        |
| ---------------------------- | -------------------------------------- | --------------------------- |
| `${HOST_PROJECT_PATH}`       | `${CONTAINER_PROJECT_PATH}`            | 项目代码                    |
| `node/npmrc`                 | `/home/docker/.npmrc`                  | npm/pnpm 配置               |
| `volta-cache` (named volume) | `/home/docker/.volta`                  | Volta 和 Node.js 版本持久化 |
| `cache/pnpm-cache`           | `/home/docker/.local/share/pnpm/store` | pnpm store                  |
| `cache/npm-cache`            | `/home/docker/.npm`                    | npm cache                   |
| `cache/yarn-cache`           | `/home/docker/.cache/yarn`             | Yarn cache                  |
| `/tmp/.X11-unix`             | `/tmp/.X11-unix`                       | X11 转发（GUI 应用）        |
| `/dev/shm`                   | `/dev/shm`                             | 共享内存                    |

## 预装依赖

Dockerfile 预装了图形界面相关的共享库（GTK、NSS、libdrm 等），支持 Cypress、Playwright、Electron 等需要 GUI 的工具。

## 使用方式

```bash
# 启动
docker compose up -d node

# 使用 pnpm（推荐）
./run.sh node "pnpm install"
./run.sh node "pnpm dev"
./run.sh node "pnpm test"

# 使用 npm
./run.sh node "npm install"

# 版本管理
./run.sh node "volta list"
./run.sh node "volta install node@20"

# 交互式 shell
docker exec -it node bash

# 使用 bin 快捷命令（需将 bin/ 加入 PATH）
pnpm install    # 等价于 ./run.sh node "pnpm install"
npm install     # 等价于 ./run.sh node "npm install"
```

## 补全支持

`run.sh` 自动传递 `COMP_*` 环境变量，`pnpm` / `npm` 的 tab 补全在容器内正常工作。
