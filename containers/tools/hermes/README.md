# Hermes Agent

NousResearch Hermes Agent — 自学习 AI 代理，提供 CLI 聊天、Gateway 多平台接入、Dashboard 和定时任务。

## 快速开始

### 首次初始化

```bash
mkdir -p /data/hermes

docker run -it --rm \
  -v /data/hermes:/opt/data \
  nousresearch/hermes-agent:v2026.6.5 setup
```

按向导提示输入 LLM 提供商的 API Key，配置写入 `/data/hermes/.env`。

### 启动服务

```bash
cd ~/develop/docker
docker compose build hermes
docker compose up -d hermes
```

### 使用

```bash
# CLI 聊天
docker exec -it hermes hermes

# 或使用 bin 快捷命令（需将 bin/ 加入 PATH）
hermes

# 查看日志
docker compose logs -f hermes

# 访问 Dashboard
open http://localhost:9119
```

## 配置说明

| 变量                    | 默认值         | 说明            |
| ----------------------- | -------------- | --------------- |
| `HERMES_VERSION`        | `v2026.6.5`    | 镜像版本        |
| `HERMES_API_PORT`       | `8642`         | API server 端口 |
| `HERMES_DASHBOARD_PORT` | `9119`         | Dashboard 端口  |
| `HERMES_DASHBOARD`      | `1`            | 启用 Dashboard  |
| `HERMES_HOST_DATA_PATH` | `/data/hermes` | 持久化数据目录  |

API Key 配置在 `/data/hermes/.env` 中，不写入 docker 仓库。

## 升级

```bash
vim .env  # 修改 HERMES_VERSION=v2026.X.XX
docker compose build hermes
docker compose up -d hermes
```

## 端口

| 端口 | 用途                               |
| ---- | ---------------------------------- |
| 8642 | API server（OpenAI 兼容 + health） |
| 9119 | Dashboard Web UI                   |

## 网络

连接 backend bridge 网络，固定 IP `172.20.0.20`，可与同网络下的 postgres、redis 等服务通信。
