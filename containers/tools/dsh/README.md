# DeepSeek Harness (dsh)

DeepSeek 官方开源 agent harness（开发预览版），基于 Cordis「一切皆插件」架构，提供 Web UI 与 headless CLI。
内置 dsh-pocket 插件：统一承载本机/局域网/公网三类入口（PIN 认证 + Host 改写，过 dsh 的 /api 信任栅栏）。

## 镜像

- **基础镜像**: `node:24.21.0-slim`
- **构建产物**: `docker-dsh:0.2.0-rc.2`
- **安装方式**: npm 全局安装 `@deepseek-ai/dsh` + `pnpm`

## 端口布局（容器内）

| 端口 | 进程 | 说明 |
| ---- | ---- | ---- |
| 3080 | dsh web | 官方安全限制：固定监听 `127.0.0.1`，拒绝绑定 0.0.0.0，不对外 |
| 3081 | dsh-pocket 代理 | **容器唯一对外口**：改写 Host/Origin 过 `/api` 信任栅栏 + PIN 认证 |

## 访问链路

```
本机:     浏览器 → 宿主 127.0.0.1:3081 ┐
局域网:   手机/台式机 → 宿主 <DSH_POCKET_LAN_IP>:3081 ├→ dsh-pocket 代理(3081, PIN) → dsh(3080)
公网:     手机 → CF 边缘(HTTPS) → cloudflared 命名隧道 → 127.0.0.1:3081 ┘
```

- 三类入口统一走 dsh-pocket 代理：PIN 认证后自动完成 dsh 会话建立，无需手动贴 token
- 首次访问各地址需过一次 PIN：本机/局域网用 LAN PIN（`/data/dsh/dsh-pocket/token-lan`），
  公网用公网 PIN（`/data/dsh/dsh-pocket/token`，或用 `DSH_POCKET_PIN` 预置的固定值）
- 局域网直连依赖 `lanIpOverride`：容器内探测到的是 Docker bridge 网段（172.x，手机不可达），
  必须指向宿主物理网卡 IP 才能生成正确的局域网链接（由 `DSH_POCKET_LAN_IP` 在启动时同步写入）
- 公网链路：手机浏览器开 `https://<DSH_POCKET_TUNNEL_HOSTNAME>` 输公网 PIN

## 配置说明

| 变量 | 默认值 | 说明 |
| ---- | ------ | ---- |
| `DSH_VERSION` | `0.2.0-rc.2` | dsh npm 包版本 |
| `DSH_NODE_VERSION` | `24.21.0` | Node 基础镜像版本（官方要求 ^22.19 或 >=24.2） |
| `DSH_HOST_DATA_PATH` | `/data/dsh` | 持久化数据（credentials、会话、dsh-pocket 设置/PIN/cloudflared） |
| `DSH_HOST_PROFILES_PATH` | dotfiles 的 `dsh/profiles` | profile 目录（git 管理，挂载须位于 `DSH_HOST_DATA_PATH` 之后） |
| `SKCTL_STORE_PATH` | skctl 存储 | agent skills（只读挂载到 `~/.agents/skills`） |
| `DSH_MEM_LIMIT` | `4g` | 内存上限 |
| `DSH_POCKET_TUNNEL_TOKEN` | 空 | Cloudflare 命名隧道 Token（仅 settings.json 不存在时写入） |
| `DSH_POCKET_TUNNEL_HOSTNAME` | 空 | 公网固定域名（如 `home-dsh.example.com`） |
| `DSH_POCKET_PROXY_PORT` | `3081` | dsh-pocket 代理端口（须与 CF Service 端口、LAN_PORT 一致） |
| `DSH_POCKET_LAN_IP` | 空 | 宿主局域网 IP（写 lanIpOverride；**每次启动同步**，IP 变化改此行重建） |
| `DSH_POCKET_LAN_PORT` | `3081` | 局域网直连宿主端口（须与 PROXY_PORT 一致） |
| `DSH_POCKET_PIN` | 空 | 固定公网 PIN（仅首次预置；**恰好 8 位**英文字母或数字） |

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

# 2. 配置 .env（HOST_* 对齐本机；填 DSH_POCKET_TUNNEL_TOKEN / HOSTNAME / LAN_IP，可选 PIN）
cp .env-example .env && vim .env

# 3. 构建并启动
docker compose build dsh && docker compose up -d dsh
```

entrypoint 幂等完成：生成 dsh-pocket `settings.json`（命名隧道模式）、预置固定 PIN、
同步 `lanIpOverride`、按 lockfile 恢复 profile 依赖（node_modules）。
cloudflared 二进制在首次开启公网时自动下载（清华镜像优先，缓存于 `/data/dsh/dsh-pocket/bin/`）。

最后在 Web UI（本机 `http://127.0.0.1:3081`）→ 设置 → 手机访问 → 点「开启公网访问」；
`/data/dsh/dsh-pocket/tunnel-auto.json` 记录启用状态，容器重启自动恢复隧道。

## 常见维护

```bash
# 局域网 IP 变化（DHCP）→ 更新 .env 后重建
vim .env  # DSH_POCKET_LAN_IP=新IP
docker compose up -d dsh --force-recreate
# 一劳永逸：在路由器给本机 MAC 绑定固定 IP

# 隧道 Token 轮换：CF 重建隧道 → 更新 .env → 删除旧 settings.json → 重建容器
vim .env  # DSH_POCKET_TUNNEL_TOKEN=<新 token>
rm /data/dsh/dsh-pocket/settings.json
docker compose up -d dsh --force-recreate
```

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

## 注意事项

- dsh 是有文件读写与命令执行能力的 agent；三类入口均有 PIN 认证保护
- 本机/局域网入口由宿主 `3081` 承载（家庭网络内可达；家宽 NAT 后公网不可达）；
  公网入口仅经 Cloudflare 隧道进出，宿主不开任何公网入站端口
- 容器内 CLI（`dsh --profile headless`）与常驻 Web 服务并存，各自独立会话
