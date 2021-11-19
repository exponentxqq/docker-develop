# 配置phpstorm断点
** .env的DOCKER_HOST_IP必须配置正确 **

## fpm phpstorm断点
1. 配置php interpreter
2. 配置xdebug端口号，默认为9999，如果需要改变，则修改`fpm/conf.d/xdebug.ini`中的`xdebug.remote_port`项
3. 配置DBGp Proxy
   1. IDE Key: docker
   2. Host: dockerhost
   3. Port: 80
4. 配置servers，需要勾选`Use path mappings`

## phpunit phpstorm断点
1. 配置php interpreter时，需要注意docker path mapping中项目路径是否有map，没有则需要手动加上
2. 配置Test Frameworks，选择remote interpreter