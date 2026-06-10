DOCKER_ROOT_DIR=$(dirname $(readlink $0))
source "$DOCKER_ROOT_DIR/.env"
project_path=$(pwd)
project_path=${project_path/#$HOST_PROJECT_PATH/$CONTAINER_PROJECT_PATH}

container_names=$(cd $DOCKER_ROOT_DIR && docker compose ps | grep -v Exit | grep -v exited | awk '{print $1}' | grep -v Name | grep -v NAME | grep -v "^-")
exists=false
for container_name in $container_names; do
  if [ "$1" == "$container_name" ]; then
    exists=true
  fi
done

if [ false == $exists ]; then
  echo "start container[$1]..."
  cd $DOCKER_ROOT_DIR && docker compose up -d $1
fi

command=$*
# 仅在 stdout 是终端时输出调试信息，避免在命令补全等场景污染输出
if [ -t 1 ]; then
  echo "[$1]current project_path: $project_path" >&2
  echo "$command" >&2
fi
command=${command#* }

tty_flag=""
# 同时检查 stdin 和 stdout 都是 TTY，避免在命令补全等场景下
# stdout 被管道捕获时仍加 -t 导致 Docker 合并 stdout/stderr
[ -t 0 ] && [ -t 1 ] && tty_flag="-t"

# 将补全相关的环境变量传入容器（pnpm / npm 等命令的 tab 补全需要）
env_args=""
for var in SHELL COMP_CWORD COMP_LINE COMP_POINT COMP_WORDS COMP_KEY COMP_TYPE; do
  [ -n "${!var+x}" ] && env_args="$env_args -e $var"
done

if [ "$1" == "redis" ]; then
  exec docker exec -i $tty_flag $env_args "$1" /bin/bash -c "$command"
elif [ "$1" == "workspace" ]; then
  exec docker exec -i $tty_flag $env_args "$1" /bin/zsh -c "[ -d $project_path ] && (cd $project_path && $command) || $command"
else
  exec docker exec -i $tty_flag $env_args "$1" /bin/bash -c "[ -d $project_path ] && (cd $project_path && $command) || $command"
fi
