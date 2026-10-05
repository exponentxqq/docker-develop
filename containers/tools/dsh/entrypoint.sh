#!/bin/bash
set -e

# 容器内端口布局：
#   3080  dsh web（官方安全限制：固定监听 127.0.0.1，拒绝绑定 0.0.0.0）
#   3081  dsh-pocket 代理（改写 Host/Origin 过 /api 信任栅栏 + PIN 认证；
#         Cloudflare 命名隧道的回源目标，见 CF Published application 的 Service 配置）
#   3090  socat（0.0.0.0:3090 → 127.0.0.1:3080，供宿主机/SSH 隧道访问，
#         由 compose 映射 127.0.0.1:${DSH_WEB_PORT}:3090 收紧到 loopback）
#
# 访问链路：
#   本机/SSH:  浏览器 → 宿主 127.0.0.1:3080 → socat(3090) → dsh(3080)
#   手机公网:  手机 → CF 边缘(HTTPS) → cloudflared 隧道 → dsh-pocket(3081) → dsh(3080)
socat TCP-LISTEN:3090,fork,reuseaddr TCP:127.0.0.1:3080 &

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

# 2) 预置固定公网 PIN（仅首次：写 token 文件 + settings 标记自定义，避免开启公网时被轮换覆盖）
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

# 3) profiles 依赖恢复：dotfiles 新 clone 后 node_modules 缺失时按 lockfile 安装
for prof in "$HOME"/.dsh/profiles/*/; do
  [ -f "${prof}package.json" ] && [ ! -d "${prof}node_modules" ] || continue
  if grep -q '"dependencies"' "${prof}package.json"; then
    echo "[entrypoint] 恢复 profile 依赖：${prof}"
    (cd "$prof" && pnpm install --frozen-lockfile) \
      || echo "[entrypoint] WARN: $(basename "$prof") 依赖恢复失败，请进容器手动 pnpm install"
  fi
done

exec "$@"
