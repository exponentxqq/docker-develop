#!/bin/bash
set -e

# dsh-pocket 初始化 · 1/4：settings.json 不存在且提供了隧道 Token → 生成命名隧道配置
# （新机器：clone dotfiles + .env 填 token，之后零手工）

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
