#!/bin/bash
set -e

# 容器内端口布局：
#   3080  dsh web（官方安全限制：固定监听 127.0.0.1，拒绝绑定 0.0.0.0）
#   3081  dsh-pocket 代理（改写 Host/Origin 过 /api 信任栅栏 + PIN 认证）
#         —— 容器唯一对外口，统一承载三类入口：
#           本机    浏览器 → 宿主 127.0.0.1:3081 → 代理
#           局域网  手机/台式机 → 宿主 <DSH_POCKET_LAN_IP>:3081 → 代理
#           公网    手机 → CF 边缘(HTTPS) → cloudflared 隧道 → 127.0.0.1:3081 → 代理
#         经 compose 映射 ${DSH_POCKET_LAN_PORT}:${DSH_POCKET_PROXY_PORT} 暴露。
#
# 容器内网卡是 Docker bridge 网段（172.x），手机可达的是宿主物理网卡 IP，
# 由 DSH_POCKET_LAN_IP 写入 lanIpOverride（见下方第 4 步）。

POCKET_DIR="$HOME/.dsh/dsh-pocket"

# ---- dsh-pocket 幂等初始化（新机器：clone dotfiles + .env 填 token，之后零手工）----

# 1) settings.json 不存在且提供了隧道 Token → 生成命名隧道配置
if [ -n "$DSH_POCKET_TUNNEL_TOKEN" ] && [ ! -f "$POCKET_DIR/settings.json" ]; then
  mkdir -p "$POCKET_DIR"
  umask 177
  cat > "$POCKET_DIR/settings.json" <<EOF
{
  "proxyPort": ${DSH_POCKET_PROXY_PORT:-3081},
  "cloudflaredPath": "$POCKET_DIR/bin/cloudflared",
  "tunnelMode": "named",
  "tunnelToken": "$DSH_POCKET_TUNNEL_TOKEN",
  "tunnelHostname": "$DSH_POCKET_TUNNEL_HOSTNAME"
}
EOF
  echo "[entrypoint] 已生成 dsh-pocket settings.json（hostname=$DSH_POCKET_TUNNEL_HOSTNAME）"
fi

# 2) 公网隧道默认开启（DSH_POCKET_TUNNEL_AUTO，默认 true）：命名隧道已配置且无「开启中」标记时
#    写入标记，插件启动 restoreTunnelIfNeeded() 自动拉起 cloudflared。
#    语义：手动关闭只维持到下次容器启动；设 false 恢复「手动关闭不跨重启」的旧行为。
if [ "${DSH_POCKET_TUNNEL_AUTO:-true}" != "false" ]; then
  POCKET_DIR="$POCKET_DIR" node -e '
    const fs = require("fs"), path = require("path");
    const dir = process.env.POCKET_DIR;
    const markerPath = path.join(dir, "tunnel-auto.json");
    let s = {};
    try { s = JSON.parse(fs.readFileSync(path.join(dir, "settings.json"), "utf8")); } catch { process.exit(0); }
    if (!s.tunnelToken) process.exit(0); // 未配置命名隧道 → 不预置
    if (fs.existsSync(markerPath)) process.exit(0); // 已有标记 → 保留原时间戳
    fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(markerPath, JSON.stringify({ at: Date.now() }), "utf8");
    console.log("[entrypoint] 已预置公网隧道开启标记（启动自动开启）");
  '
fi

# 3) 预置固定公网 PIN（仅首次：写 token 文件 + settings 标记自定义，避免开启公网时被轮换覆盖）
#    注意格式限制：恰好 8 位英文字母或数字（插件 PIN_RE 校验，不合规值会被忽略并重新随机）
if [ -n "$DSH_POCKET_PIN" ] && [ ! -f "$POCKET_DIR/token" ]; then
  mkdir -p "$POCKET_DIR"
  printf '%s' "$DSH_POCKET_PIN" > "$POCKET_DIR/token"
  chmod 600 "$POCKET_DIR/token"
  DSH_POCKET_PIN="$DSH_POCKET_PIN" POCKET_DIR="$POCKET_DIR" node -e '
    const fs = require("fs"), p = process.env.POCKET_DIR + "/settings.json";
    try {
      const s = JSON.parse(fs.readFileSync(p, "utf8"));
      s.publicPinCustom = true;
      fs.writeFileSync(p, JSON.stringify(s, null, 2), { mode: 0o600 });
    } catch { /* settings 不存在时跳过标记 */ }
  '
  echo "[entrypoint] 已预置 dsh-pocket 公网 PIN"
fi

# 4) 局域网 IP 覆盖同步（拓扑参数：DSH_POCKET_LAN_IP 非空时每次启动以 .env 为准；
#    为空则不管理该键，交由设置页手动选择。IP 变化时改 .env 重建容器即可）
if [ -n "$DSH_POCKET_LAN_IP" ]; then
  DSH_POCKET_LAN_IP="$DSH_POCKET_LAN_IP" POCKET_DIR="$POCKET_DIR" node -e '
    const fs = require("fs"), path = require("path");
    const p = path.join(process.env.POCKET_DIR, "settings.json");
    let s = {};
    try { s = JSON.parse(fs.readFileSync(p, "utf8")); } catch { /* 无文件 → 新建 */ }
    if (s.lanIpOverride !== process.env.DSH_POCKET_LAN_IP) {
      s.lanIpOverride = process.env.DSH_POCKET_LAN_IP;
      fs.mkdirSync(process.env.POCKET_DIR, { recursive: true });
      fs.writeFileSync(p, JSON.stringify(s, null, 2), { mode: 0o600 });
      console.log("[entrypoint] 已同步 lanIpOverride = " + s.lanIpOverride);
    }
  '
fi

# 5) profiles 依赖恢复：dotfiles 新 clone 后 node_modules 缺失时按 lockfile 安装
for prof in "$HOME"/.dsh/profiles/*/; do
  [ -f "${prof}package.json" ] && [ ! -d "${prof}node_modules" ] || continue
  if grep -q '"dependencies"' "${prof}package.json"; then
    echo "[entrypoint] 恢复 profile 依赖：${prof}"
    (cd "$prof" && pnpm install --frozen-lockfile) \
      || echo "[entrypoint] WARN: $(basename "$prof") 依赖恢复失败，请进容器手动 pnpm install"
  fi
done

exec "$@"
