#!/bin/bash
set -e

# dsh-pocket 初始化 · 2/4：公网隧道默认开启（DSH_POCKET_TUNNEL_AUTO，默认 true）：
# 命名隧道已配置且无「开启中」标记时写入标记，插件启动 restoreTunnelIfNeeded() 自动拉起 cloudflared。
# 语义：手动关闭只维持到下次容器启动；设 false 恢复「手动关闭不跨重启」的旧行为。

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
