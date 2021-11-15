DOCKER_ROOT_DIR=$(dirname $0)
source $DOCKER_ROOT_DIR/.env
project_path=$(pwd)
project_path=${project_path/#$HOST_PROJECT_PATH/$CONTAINER_PROJECT_PATH}

container_names=$(cd $DOCKER_ROOT_DIR && docker-compose ps | grep -v Exit | grep -v exited | awk '{print $1}' | grep -v Name | grep -v NAME | grep -v "^-")
exists=false
for container_name in $container_names
do
    if [ "$1" == "$container_name" ]; then
        exists=true
    fi
done

if [ false == $exists ]; then
    echo "start container[$1]..."
    cd $DOCKER_ROOT_DIR && docker-compose up -d $1
fi

echo "[$1]current project_path: $project_path"
command=$*
echo $command
command=${command#* }

if [ "$1" == "redis" ]; then
    docker exec -it "$1" /bin/bash -c "$command"
elif [ "$1" == "workspace" ]; then
    docker exec -it "$1" /bin/zsh -c "[ -d $project_path ] && (cd $project_path && $command) || $command"
else
    docker exec -it "$1" /bin/bash -c "[ -d $project_path ] && (cd $project_path && $command) || $command"
fi
