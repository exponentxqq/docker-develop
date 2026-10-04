#!/bin/bash
set -e

# dsh 官方出于安全考虑拒绝绑定 0.0.0.0（error: --host 0.0.0.0 is intentionally not supported），
# 固定监听 127.0.0.1:3080。这里用 socat 把容器的 0.0.0.0:3081 转发给它，再由 compose 端口映射暴露：
#
#   浏览器 → 宿主 127.0.0.1:3080 → 容器 0.0.0.0:3081 (socat) → 容器 127.0.0.1:3080 (dsh)
#
# 宿主端口（DSH_WEB_PORT=3080）刻意与 dsh 实际监听端口一致：
#   - dsh 打印的带 token 启动 URL 在宿主机上原样可用
#   - 浏览器 Host 头为 127.0.0.1:3080（loopback），可通过 dsh 的 /api 信任栅栏
#   - http://127.0.0.1 满足浏览器安全上下文要求（crypto.randomUUID 等 API 可用）
socat TCP-LISTEN:3081,fork,reuseaddr TCP:127.0.0.1:3080 &

exec "$@"
