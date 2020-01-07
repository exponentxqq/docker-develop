project_path=$(pwd)
container_names=`cd /develop/docker && docker-compose ps | awk '{print $1}' | grep -v Name | grep -v "^-"`
exists=false
for container_name in $container_names
do
    if [[ $1 == $container_name ]]; then
        exists=true
    fi
done

if [ false == $exists ]; then
    echo "$1 container_name not exists"
    echo "current containers: $container_names"
    exit 1;
fi

echo "[$1]current project_path: $project_path"
command=$*
command=${command#* }

if [[ $1 == "redis" ]]; then
    docker exec -it $1 /bin/bash -c "$command"
elif [[ $1 == "workspace" ]]; then
    docker exec -it $1 /bin/zsh -c "[ -d $project_path ] && (cd $project_path && $command) || $command"
else
    docker exec -it $1 /bin/bash -c "[ -d $project_path ] && (cd $project_path && $command) || $command"
fi
