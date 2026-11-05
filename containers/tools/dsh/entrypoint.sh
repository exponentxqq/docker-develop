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
# 由 DSH_POCKET_LAN_IP 写入 lanIpOverride（见 entrypoint.d/40-pocket-lan-ip.sh）。
#
# 初始化步骤拆分在 entrypoint.d/（按文件名序执行，每步一个独立 bash 子进程，
# 互不污染变量；各脚本自带 set -e，失败语义与拆分前一致：除脚本内显式容错点
# （60 的依赖恢复 WARN、70 的浏览器 WARN）外，失败随主脚本 set -e 中止启动）：
#   10-pocket-init.sh         dsh-pocket settings.json 生成（隧道 token）
#   20-pocket-tunnel-auto.sh  公网隧道自动开启标记
#   30-pocket-pin.sh          固定公网 PIN 预置
#   40-pocket-lan-ip.sh       lanIpOverride 同步
#   50-pnpm-store.sh          pnpm 全局 store 配置
#   60-profile-deps.sh        profiles 依赖恢复
#   70-shared-chromium.sh     常驻共享浏览器（browser-use attach，:9222）

export POCKET_DIR="$HOME/.dsh/dsh-pocket"

for step in /home/docker/entrypoint.d/*.sh; do
  [ -e "$step" ] || continue
  bash "$step"
done

# 会话 PATH 注入（刻意置于 entrypoint 逻辑之后）：dsh 进程及其全部子进程（AI 会话 shell）
# 继承前置的 docker 包装脚本目录，命令与宿主同构。60-profile-deps.sh 的 profile 依赖恢复
# 在注入之前执行，继续使用容器内原生 pnpm。
export PATH="${HOST_PROJECT_PATH:-/home/xuqinqin/develop}/docker/bin:$PATH"

exec "$@"
