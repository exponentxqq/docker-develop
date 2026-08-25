DOCKER_ROOT_DIR=$(dirname $(readlink -f "$0"))
source "$DOCKER_ROOT_DIR/.env"
project_path=$(pwd)
# project_path=${project_path/#$HOST_PROJECT_PATH/$CONTAINER_PROJECT_PATH}

container_names=$(cd "$DOCKER_ROOT_DIR" && docker compose ps | grep -v Exit | grep -v exited | awk '{print $1}' | grep -v Name | grep -v NAME | grep -v "^-")
exists=false
for container_name in $container_names; do
  if [ "$1" == "$container_name" ]; then
    exists=true
  fi
done

if [ false == $exists ]; then
  echo "start container[$1]..."
  cd "$DOCKER_ROOT_DIR" && docker compose up -d "$1"
fi

# 单参数（用户传入一个带 shell 语法的字符串）→ 原样交给 bash 重解析，保留管道/&& 等用法
# 多参数 → 逐参数 %q 转义后重组，精确保留引号边界（旧版 $* 拍平会丢失引号）
if [ $# -le 2 ]; then
  command="${2:-}"
else
  command=""
  for arg in "${@:2}"; do
    command+=" $(printf '%q' "$arg")"
  done
fi
# 仅在 stdout 是终端时输出调试信息，避免在命令补全等场景污染输出
if [ -t 1 ]; then
  echo "[$1]current project_path: $project_path" >&2
  echo "$command" >&2
fi

tty_flag=""
# 同时检查 stdin 和 stdout 都是 TTY，避免在命令补全等场景下
# stdout 被管道捕获时仍加 -t 导致 Docker 合并 stdout/stderr
[ -t 0 ] && [ -t 1 ] && tty_flag="-t"

# 将补全相关的环境变量传入容器（pnpm / npm 等命令的 tab 补全需要）
env_args=""
for var in SHELL COMP_CWORD COMP_LINE COMP_POINT COMP_WORDS COMP_KEY COMP_TYPE; do
  [ -n "${!var+x}" ] && env_args="$env_args -e $var"
done

project_path_q=$(printf '%q' "$project_path")
if [ "$1" == "redis" ]; then
  exec docker exec -i $tty_flag $env_args "$1" /bin/bash -c "$command"
else
  exec docker exec -i $tty_flag $env_args "$1" /bin/bash --login -c "if [ -d $project_path_q ]; then cd $project_path_q || exit 1; fi;$command"
fi
