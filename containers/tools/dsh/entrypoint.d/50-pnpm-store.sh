#!/bin/bash
set -e

# pnpm 全局 store 配置：统一到宿主默认路径（三端共享）。~/.config/pnpm/rc 为 pnpm
# 专有配置文件，npm 不读取——避免 npm 对 pnpm 专有键（store-dir）的未知配置警告

PNPM_RC="$HOME/.config/pnpm/rc"
mkdir -p "$(dirname "$PNPM_RC")"
if ! grep -qs '^store-dir=' "$PNPM_RC"; then
  printf 'store-dir=/home/xuqinqin/.local/share/pnpm/store\n' >> "$PNPM_RC"
fi
