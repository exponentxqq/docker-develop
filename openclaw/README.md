# OpenClaw Docker 部署

基于官方镜像 `ghcr.io/openclaw/openclaw:latest` 运行 OpenClaw Gateway。

## 前置条件

- 已卸载本机 yay 安装的 openclaw
- 配置目录 `~/.openclaw` 已存在（含 openclaw.json、.env、extensions 等）

## 启动

```bash
cd /home/xuqinqin/develop/docker/openclaw
docker compose up -d
```

## 停止

```bash
docker compose down
```

## 访问

- 控制台：http://127.0.0.1:18789/
- Token 见 `~/.openclaw/openclaw.json` 的 `gateway.auth.token`

## 使用 CLI（可选）

```bash
docker compose --profile cli run --rm openclaw-cli gateway status
docker compose --profile cli run --rm openclaw-cli dashboard --no-open
```

## 配置说明

- 配置目录挂载自 `~/.openclaw`，DeepSeek API Key 等从 `~/.openclaw/.env` 读取
- 修改配置后执行 `docker compose restart` 生效
