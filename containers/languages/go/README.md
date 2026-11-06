# Go

Go 语言开发容器，基于官方 golang 镜像。

## 镜像

- **基础镜像**: `golang:${GO_VERSION}`（版本由根 `.env` 的 `GO_VERSION` 驱动）
- **构建产物**: `docker-go:latest`
- **工具链和缓存挂载到宿主机**以实现持久化

## 端口

| 端口 | 用途              |
| ---- | ----------------- |
| 3000 | 默认 Web 应用端口 |

## 挂载

| 宿主机路径                     | 容器路径                       | 说明                          |
| ------------------------------ | ------------------------------ | ----------------------------- |
| `${HOST_HOME}`                 | `${HOST_HOME}`                 | 宿主 home（路径一致）         |
| `${HOST_HOME}/go`              | `/home/docker/go`              | GOPATH/模块缓存与宿主共享     |
| `${HOST_HOME}/.cache/go-build` | `/home/docker/.cache/go-build` | 构建缓存（GOCACHE）与宿主共享 |
| `/data/tmp`                    | `/tmp`                         | 临时目录                      |

> **注意**: 官方镜像自带 `ENV GOPATH=/go`，Dockerfile 已覆盖为 `/home/docker/go`。`go install` 的工具落在 `$GOPATH/bin`（宿主侧 `~/go/bin`）；gopls 由镜像构建期装到 `/usr/local/bin`，不受挂载影响。

## 使用方式

```bash
# 启动
docker compose up -d go

# 编译和运行
./run.sh go "go build ./..."
./run.sh go "go run main.go"

# 测试
./run.sh go "go test ./..."

# 依赖管理
./run.sh go "go mod tidy"
./run.sh go "go mod download"

# 交互式 shell
docker exec -it go bash
```
