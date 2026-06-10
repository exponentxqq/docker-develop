# Go

Go 语言开发容器，基于官方 golang 镜像。

## 镜像

- **基础镜像**: `golang:latest`（官方最新稳定版）
- **构建产物**: `docker-go:latest`
- **工具链和缓存挂载到宿主机**以实现持久化

## 端口

| 端口 | 用途              |
| ---- | ----------------- |
| 3000 | 默认 Web 应用端口 |

## 挂载

| 宿主机路径             | 容器路径                    | 说明                  |
| ---------------------- | --------------------------- | --------------------- |
| `${HOST_PROJECT_PATH}` | `${CONTAINER_PROJECT_PATH}` | 项目代码              |
| `cache/go-cache`       | `/usr/local/go`             | Go 工具链和缓存持久化 |

> **注意**: `/usr/local/go` 的挂载会覆盖容器内 Go 安装目录。首次使用前需确保 `cache/go-cache` 包含完整的 Go 发行版，或手动初始化。

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
