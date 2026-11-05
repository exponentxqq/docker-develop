#!/bin/bash
set -e

# dsh-pocket 初始化 · 3/4：预置固定公网 PIN（仅首次：写 token 文件 + settings 标记自定义，
# 避免开启公网时被轮换覆盖）
# 注意格式限制：恰好 8 位英文字母或数字（插件 PIN_RE 校验，不合规值会被忽略并重新随机）

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
