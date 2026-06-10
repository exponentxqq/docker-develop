# PHP-FPM

PHP 7.2 FPM 容器，集成 Composer、Xdebug 和多个可选扩展，支持 PhpStorm 断点调试。

## 镜像

- **基础镜像**: `php:7.2-fpm`（通过 `PHP_VERSION` 环境变量控制）
- **构建产物**: `docker-fpm:7.2`

## 已安装扩展

### 始终安装

| 扩展               | 用途                      |
| ------------------ | ------------------------- |
| pdo_mysql / mysqli | MySQL 数据库              |
| gd                 | 图片处理（JPEG/PNG/WebP） |
| zip                | 压缩文件                  |
| pcntl / posix      | 进程控制                  |
| exif               | 图片 EXIF 信息            |
| gettext            | 国际化                    |
| sockets            | 网络通信                  |
| ldap               | LDAP 认证                 |

### 可选扩展（通过 `.env` 控制）

| 扩展     | 变量                   | 默认值  | 说明                 |
| -------- | ---------------------- | ------- | -------------------- |
| Composer | `PHP_INSTALL_COMPOSER` | `true`  | 依赖管理             |
| Xdebug   | `PHP_INSTALL_XDEBUG`   | `true`  | 断点调试             |
| Redis    | `PHP_INSTALL_REDIS`    | `false` | Redis 客户端         |
| Jieba    | `PHP_INSTALL_JIEBA`    | `false` | 中文分词             |
| Swoole   | `PHP_INSTALL_SWOOLE`   | `false` | 协程网络引擎         |
| Imagick  | `PHP_INSTALL_IMAGICK`  | `false` | ImageMagick 图片处理 |
| Phalcon  | `PHP_INSTALL_PHALCON`  | `false` | 高性能 PHP 框架      |

## 内置工具

| 工具            | 用途                   |
| --------------- | ---------------------- |
| composer        | PHP 依赖管理（版本 2） |
| phpunit (7.1.5) | 单元测试               |
| git             | 版本控制               |
| zsh (oh-my-zsh) | Shell 环境             |
| docker-ce-cli   | 容器内操作 Docker      |

## 端口

| 端口 | 用途                                         |
| ---- | -------------------------------------------- |
| 9000 | FPM 默认端口，映射到宿主机 `${PHP_FPM_PORT}` |

## 挂载

| 宿主机路径             | 容器路径                     | 说明                               |
| ---------------------- | ---------------------------- | ---------------------------------- |
| `${HOST_PROJECT_PATH}` | `${CONTAINER_PROJECT_PATH}`  | 项目代码                           |
| `fpm/php.ini`          | `/usr/local/etc/php/php.ini` | PHP 配置                           |
| `fpm/conf.d/`          | `/usr/local/etc/php.conf/`   | PHP 扩展配置（xdebug, redis 等）   |
| `cache/composer-cache` | `/home/docker/.composer`     | Composer 缓存                      |
| `common/.zshrc`        | `/home/docker/.zshrc`        | Zsh 配置                           |
| `common/.vimrc`        | `/home/docker/.vimrc`        | Vim 配置                           |
| `/var/run/docker.sock` | `/var/run/docker.sock`       | Docker socket（容器内操作 Docker） |

## 使用方式

```bash
# 启动
docker compose up -d fpm

# Composer 操作
./run.sh fpm "composer install"
./run.sh fpm "composer require vendor/package"

# 运行测试
./run.sh fpm "phpunit"

# 执行 PHP 脚本
./run.sh fpm "php artisan migrate"

# 交互式 shell
docker exec -it fpm bash
```

## PhpStorm 断点调试

### 前提条件

1. `.env` 中 `DOCKER_HOST_IP` 必须配置为宿主机 IP
2. `PHP_INSTALL_XDEBUG=true`

### 配置步骤

1. **配置 PHP Interpreter**
   - Settings → PHP → CLI Interpreter → 添加 Remote Interpreter（Docker Compose）
   - 选择 `fpm` 服务

2. **配置 Xdebug 端口**
   - 默认端口 9999，如需修改编辑 `fpm/conf.d/xdebug.ini` 中的 `xdebug.remote_port`

3. **配置 DBGp Proxy**
   - IDE Key: `docker`
   - Host: `dockerhost`
   - Port: `80`

4. **配置 Servers**
   - 勾选 `Use path mappings`
   - 确保项目路径映射正确

### PHPUnit 断点

配置 Test Frameworks 时：

- 选择 Remote Interpreter（即上面配置的 fpm interpreter）
- 检查 Docker path mapping 中项目路径映射

## 配置目录结构

```
fpm/
├── Dockerfile
├── README.md
├── php.ini           # 主 PHP 配置（约 70KB，完整配置）
├── php-fpm.conf      # FPM 进程管理配置
├── phpunit-7.1.5.phar # PHPUnit 可执行文件
├── conf.d/           # 各扩展独立配置
│   ├── xdebug.ini
│   ├── redis.ini
│   ├── swoole.ini
│   └── ...
└── pool.d/           # FPM 进程池配置
```
