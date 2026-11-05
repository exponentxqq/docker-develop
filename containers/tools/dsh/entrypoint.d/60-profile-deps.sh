#!/bin/bash
set -e

# profiles 依赖恢复：dotfiles 新 clone 后 node_modules 缺失时按 lockfile 安装
# （刻意在 PATH 注入之前执行，使用容器内原生 pnpm——见主 entrypoint.sh）

for prof in "$HOME"/.dsh/profiles/*/; do
  [ -f "${prof}package.json" ] && [ ! -d "${prof}node_modules" ] || continue
  if grep -q '"dependencies"' "${prof}package.json"; then
    echo "[entrypoint] 恢复 profile 依赖：${prof}"
    (cd "$prof" && pnpm install --frozen-lockfile) \
      || echo "[entrypoint] WARN: $(basename "$prof") 依赖恢复失败，请进容器手动 pnpm install"
  fi
done
