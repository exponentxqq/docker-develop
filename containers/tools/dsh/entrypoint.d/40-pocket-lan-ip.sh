#!/bin/bash
set -e

# dsh-pocket 初始化 · 4/4：局域网 IP 覆盖同步（拓扑参数：DSH_POCKET_LAN_IP 非空时每次启动
# 以 .env 为准；为空则不管理该键，交由设置页手动选择。IP 变化时改 .env 重建容器即可）

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
