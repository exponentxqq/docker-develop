#!/bin/bash
# 常驻共享浏览器（browser-use attach 模式）：chrome-devtools-mcp 多会话 attach 同一实例
# （profile 配置 mode: attach + endpoint: http://127.0.0.1:9222）。
# 走 chromium-launch wrapper（~/.dsh/bin/，注入 --no-sandbox / --disable-dev-shm-usage，
# 容器 seccomp 禁 userns 与 /dev/shm 64M 限制必需）；wrapper 缺失回退 /usr/bin/chromium
# 手动补参。幂等：9222 已活则跳过；启动前清理 user-data-dir 中陈旧的
# Chromium Singleton 锁（容器重建/强杀后残留，指向已消失容器的主机名+pid，
# chromium 会视为远端实例存活而拒绝启动）；输出记入 /tmp/dsh-chromium.log 便于排障。
# 本脚本任何失败只 WARN 不阻断启动——dsh web 优先于浏览器可用性。
set -u

CHROME_URL="http://127.0.0.1:9222/json/version"
CHROME_ARGS="--headless --remote-debugging-address=127.0.0.1 --remote-debugging-port=9222 --user-data-dir=$HOME/.dsh/chromium-shared about:blank"

if curl -sf "$CHROME_URL" >/dev/null 2>&1; then
  exit 0
fi

# 清理陈旧 Singleton 锁：user-data-dir 在持久卷上，跨容器代际残留；
# 锁内主机名属于旧容器，chromium 尝试联络旧 SingletonSocket 失败后直接退出
rm -f "$HOME/.dsh/chromium-shared/SingletonLock" \
      "$HOME/.dsh/chromium-shared/SingletonCookie" \
      "$HOME/.dsh/chromium-shared/SingletonSocket" 2>/dev/null || true

if [ -x "$HOME/.dsh/bin/chromium-launch" ]; then
  nohup "$HOME/.dsh/bin/chromium-launch" $CHROME_ARGS >>/tmp/dsh-chromium.log 2>&1 &
elif [ -x /usr/bin/chromium ]; then
  nohup /usr/bin/chromium --no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage $CHROME_ARGS >>/tmp/dsh-chromium.log 2>&1 &
else
  echo "[entrypoint] WARN: 未找到 chromium，跳过常驻共享浏览器" >&2
  exit 0
fi

for _ in $(seq 1 20); do
  if curl -sf "$CHROME_URL" >/dev/null 2>&1; then
    echo "[entrypoint] 常驻共享浏览器就绪 :9222"
    exit 0
  fi
  sleep 0.5
done
echo "[entrypoint] WARN: 共享浏览器 10s 内未就绪（browser-use attach 将不可用，web 不受影响）" >&2
