#!/bin/bash
# codebase-memory（CBM）残留 daemon socket 清理。
#
# 背景：CBM 的 MCP（codebase-memory-mcp）启动时须先拉起后台 daemon，daemon 以 unix
# socket 通信（/tmp/cbm-daemon-<uid>/cbm-<缓存指纹哈希>.sock/.anc；/tmp 即宿主
# /data/tmp，跨容器代际与宿主共享）。容器重启会把本代际内活跃的 daemon 硬杀，
# socket 三件套（.sock / .sock.identity / .anc）残留；新代际 daemon 启动时
# namespace_validation 阶段发现 socket 已存在（EEXIST）且 identity 令牌属于旧
# 命名空间，拒绝接管 → daemon 启动失败 → dsh 的 mcp 客户端重试约 3 分钟后放弃，
# codebase-memory MCP 断连且不再自愈（2026-11-23 事故实录；事后修复须热切换
# mcp-codebase-memory 条目或重启 profile）。
#
# 策略：entrypoint 阶段（dsh 启动前）逐 socket 用 node 做 connect 探活——
#   连接成功     → 有存活 daemon（宿主侧或共享 /data/tmp 的其他容器）持有，保留；
#   ECONNREFUSED → 无监听者的死 socket，删除三件套。flock 类文件（.lock/
#     .lifetime.lock/.startup-v2.lock）不删：持有进程死亡即自动释放，新 daemon
#     可重新获取（实测仅删三件套即可恢复启动）；
#   其他错误/超时 → 状态不确定，保守保留并 WARN。
# 幂等；任何失败只 WARN 不阻断启动——dsh web 可用性优先。
set -u

probe() {  # $1=socket 路径；退出码 0=存活 1=死socket 2=不确定
  node -e '
const net = require("net");
const s = net.connect({ path: process.argv[1] });
s.setTimeout(500);
s.on("connect", () => process.exit(0));
s.on("error", (e) => process.exit(e.code === "ECONNREFUSED" || e.code === "ENOENT" ? 1 : 2));
s.on("timeout", () => process.exit(2));
' "$1" 2>/dev/null
}

declare -A seen=()
for f in /tmp/cbm-daemon-*/cbm-*.sock /tmp/cbm-daemon-*/cbm-*.anc; do
  [ -S "$f" ] || continue
  base="${f%.*}"                       # cbm-<hash>（剥掉 .sock/.anc 后缀）
  [ -n "${seen[$base]:-}" ] && continue
  seen[$base]=1

  alive=0; dead=0; uncertain=0
  for s in "$base.sock" "$base.anc"; do
    [ -S "$s" ] || continue
    probe "$s"; rc=$?
    case $rc in
      0) alive=1 ;;
      1) dead=1 ;;
      *) uncertain=1 ;;
    esac
  done

  if [ "$alive" -eq 1 ]; then
    continue                           # 存活 daemon 持有（宿主/他容器）——不动
  elif [ "$uncertain" -eq 1 ]; then
    echo "[entrypoint] WARN: CBM socket $base.sock 探活不确定，保留不清理" >&2
    continue
  elif [ "$dead" -eq 1 ]; then
    rm -f "$base.sock" "$base.sock.identity" "$base.anc" 2>/dev/null || true
    echo "[entrypoint] 已清理 CBM 残留 daemon socket：$base.sock（含 .sock.identity/.anc）"
  fi
done

exit 0
