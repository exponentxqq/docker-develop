# DeepSeek Harness (dsh)

DeepSeek 官方开源 agent harness（开发预览版），基于 Cordis「一切皆插件」架构，提供 Web UI 与 headless CLI。
内置 dsh-pocket 插件，支持手机公网访问（Cloudflare 命名隧道 + PIN 认证）。

## 镜像

- **基础镜像**: `node:24.21.0-slim`
- **构建产物**: `docker-dsh:0.2.0-rc.2`
- **安装方式**: npm 全局安装 `@deepseek-ai/dsh` + `pnpm`

## 端口布局（容器内）

| 端口 | 进程 | 说明 |
| ---- | ---- | ---- |
| 3080 | dsh web | 官方安全限制：固定监听 `127.0.0.1`，拒绝绑定 0.0.0.0 |
| 3081 | dsh-pocket 代理 | 改写 Host/Origin 过 `/api` 信任栅栏 + PIN 认证；**CF 隧道回源目标** |
| 3090 | socat | `0.0.0.0:3090 → 127.0.0.1:3080`，供宿主/SSH 隧道访问 |

## 访问链路

```
本机/SSH:   浏览器 → 宿主 127.0.0.1:3080 →(compose 映射, 仅 loopback)→ socat(3090) → dsh(3080)

手机公网:   手机 → CF 边缘(HTTPS 自动证书) → cloudflared 命名隧道(容器内出站)
                 → dsh-pocket 代理(3081, PIN 认证) → dsh(3080)
```

- 本机链路首次用启动日志里的 token URL 换 30 天 cookie（密钥持久化在 `/data/dsh/.credentials.yaml`，
  容器重启不失效）；固定使用 `http://127.0.0.1:3080`，勿与 `localhost` 混用（cookie 绑定 authority）
- 公网链路：dsh 启动时打印的地址与宿主一致；手机浏览器开 `https://<DSH_POCKET_TUNNEL_HOSTNAME>` 输 PIN

## 配置说明

| 变量 | 默认值 | 说明 |
| ---- | ------ | ---- |
| `DSH_VERSION` | `0.2.0-rc.2` | dsh npm 包版本 |
| `DSH_NODE_VERSION` | `24.21.0` | Node 基础镜像版本（官方要求 ^22.19 或 >=24.2） |
| `DSH_WEB_PORT` | `3080` | Web UI 宿主机端口（仅绑 127.0.0.1） |
| `DSH_HOST_DATA_PATH` | `/data/dsh` | 持久化数据（credentials、会话、dsh-pocket 设置/PIN/cloudflared） |
| `DSH_HOST_PROFILES_PATH` | dotfiles 的 `dsh/profiles` | profile 目录（git 管理，挂载须位于 `DSH_HOST_DATA_PATH` 之后） |
| `SKCTL_STORE_PATH` | skctl 存储 | agent skills（只读挂载到 `~/.agents/skills`） |
| `DSH_MEM_LIMIT` | `4g` | 内存上限 |
| `DSH_POCKET_TUNNEL_TOKEN` | 空 | Cloudflare 命名隧道 Token（仅新机器初始化时写入 settings.json） |
| `DSH_POCKET_TUNNEL_HOSTNAME` | 空 | 公网固定域名（如 `home-dsh.example.com`） |
| `DSH_POCKET_PROXY_PORT` | `3081` | dsh-pocket 代理端口（须与 CF Service 端口一致） |
| `DSH_POCKET_PIN` | 空 | 固定公网 PIN（仅首次预置；8–64 位字母数字） |

## 数据与挂载

| 宿主路径 | 容器路径 | 说明 |
| -------- | -------- | ---- |
| `/data/dsh` | `/home/docker/.dsh` | credentials、会话、dsh-pocket（settings/PIN/cloudflared） |
| `~/develop/dotfiles/dsh/profiles` | `/home/docker/.dsh/profiles` | profile 定义 + 插件（git 管理 node_modules 忽略） |
| `${HOST_PROJECT_PATH}` | 同路径 | 项目工作区（Web UI 目录选择器） |
| `${SKCTL_STORE_PATH}/skills` | `/home/docker/.agents/skills` | agent skills（只读） |

## 新机器部署（固化流程）

前置：Cloudflare 侧域名 zone 已接入 CF，且已建命名隧道 + Published application
（Hostname `<DSH_POCKET_TUNNEL_HOSTNAME>` → Service `HTTP://127.0.0.1:3081`）。

```bash
# 1. dotfiles 就位（profiles 含插件声明 package.json + pnpm-lock.yaml）
git clone <dotfiles-repo> ~/develop/dotfiles

# 2. 配置 .env（HOST_* 对齐本机；填 DSH_POCKET_TUNNEL_TOKEN / HOSTNAME，可选 PIN）
cp .env-example .env && vim .env

# 3. 构建并启动
docker compose build dsh && docker compose up -d dsh
```

entrypoint 幂等完成：生成 dsh-pocket `settings.json`（命名隧道模式）、预置固定 PIN、
按 lockfile 恢复 profile 依赖（node_modules）。cloudflared 二进制在首次开启公网时
自动下载（清华镜像优先，缓存于 `/data/dsh/dsh-pocket/bin/`）。

最后在 Web UI（本机链路）→ 设置 → 手机访问 → 点「开启公网访问」即可；
`/data/dsh/dsh-pocket/tunnel-auto.json` 记录启用状态，容器重启自动恢复隧道。

## CLI 用法

```bash
dsh --version                              # 经 bin/dsh 包装脚本（run.sh dsh dsh ...）
dsh --profile headless "跑一下单元测试"     # 一次性任务
dsh plugin --profile web add <包名>        # 插件管理（写入 dotfiles 的 profile，记得提交）
```

## 升级与备份

```bash
vim .env  # 修改 DSH_VERSION
docker compose build dsh && docker compose up -d dsh
```

- dsh 处于 developer preview，升级前备份 `/data/dsh`（credentials、会话、dsh-pocket 配置）
- 隧道 Token 轮换：CF 重建隧道 → 更新 `.env` 的 `DSH_POCKET_TUNNEL_TOKEN` →
  删除 `/data/dsh/dsh-pocket/settings.json` → 重建容器（entrypoint 会重新生成）

## 注意事项

- dsh 是有文件读写与命令执行能力的 agent；公网入口有三层防护（CF 边缘 + 固定 PIN + dsh cookie）
- 端口映射仅绑宿主 `127.0.0.1`，公网流量全部走 Cloudflare 隧道，宿主不暴露端口
- 容器内 CLI（`dsh --profile headless`）与常驻 Web 服务并存，各自独立会话
