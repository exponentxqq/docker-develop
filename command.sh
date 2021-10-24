docker run --name mysql -p 3306:3306 -v ~/docker/mysql/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=123456 -itd develop/mysql

docker run --name php-fpm -p 9000:9000 --link mysql:mysql -v ~/develop:/www --privileged=true -d develop/php

docker run --name nginx -p 80:80 --link php-fpm:php-fpm -v ~/develop:/www -v ~/docker/nginx/log/:/nginx/log --privileged=true -d develop/nginx

docker exec -it php-fpm /bin/bash

docker run -it --rm --entrypoint=bash -v /develop:/develop nginx

docker inspect --format='{{.NetworkSettings.IPAddress}}' php-fpm  #查看php-fpm容器的ip地址

$ wget -qO- https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/6.4.2/flyway-commandline-6.4.2-linux-x64.tar.gz | tar xvz && sudo ln -s `pwd`/flyway-6.4.2/flyway /usr/local/bin 