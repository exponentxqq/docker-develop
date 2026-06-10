# Nginx

Nginx 反向代理容器，支持静态站点、PHP 站点代理、HTTPS 自签证书，可自由扩展站点配置。

## 镜像

- **基础镜像**: `nginx:1.28.0`（通过 `NGINX_VERSION` 环境变量控制）
- **构建产物**: `docker-nginx:1.28.0`

## 端口

| 端口 | 用途  |
| ---- | ----- |
| 80   | HTTP  |
| 443  | HTTPS |

## 挂载

| 宿主机路径             | 容器路径                    | 说明                              |
| ---------------------- | --------------------------- | --------------------------------- |
| `nginx/nginx.conf`     | `/etc/nginx/nginx.conf`     | 主配置（worker、日志、gzip）      |
| `nginx/site-enabled/`  | `/etc/nginx/conf.d/`        | 站点配置（一个 `.conf` 一个站点） |
| `nginx/ssl/`           | `/etc/nginx/ssl/`           | SSL 证书目录                      |
| `nginx/log/`           | `/nginx/log/`               | 访问日志和错误日志                |
| `${HOST_PROJECT_PATH}` | `${CONTAINER_PROJECT_PATH}` | 项目代码（静态文件、PHP 代码）    |

## 主配置 (`nginx.conf`)

- worker_processes: 4
- gzip 已启用
- worker_connections: 1024
- 临时文件目录: `/tmp/nginx_*_temp`
- 日志格式: main（含 `$http_x_forwarded_for`）

## 站点配置

站点配置文件位于 `nginx/site-enabled/`，通过 `include /etc/nginx/conf.d/*.conf` 自动加载。

### 静态站点示例 (`child.conf`)

```nginx
server {
    charset utf-8;
    client_max_body_size 128M;
    listen 80;
    server_name www.example.localhost;

    root /develop/path/to/static/site;
    index index.html index.htm;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

### PHP 站点示例

```nginx
server {
    charset utf-8;
    client_max_body_size 128M;
    listen 80;
    server_name www.example.localhost;

    root /develop/path/to/php/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass fpm:9000;
        try_files $uri = 404;
    }
}
```

### 资源代理 (`resource.conf`)

用于代理静态资源（如图片、文件），配置自定义端口和目录。

## HTTPS 配置

```bash
# 1. 编辑 ssl/ssl.conf，修改 DNS.1 为你的域名
# 2. 执行 ssl/generate-cert.sh 生成自签证书
#    注意：Common Name 必须填站点域名，可用 *.xxx.localhost
# 3. 在站点配置中增加：
#    listen 443 ssl;
#    ssl_certificate ssl/local.crt;
#    ssl_certificate_key ssl/local.key;
# 4. 重启 nginx
docker compose restart nginx
```

## 使用方式

```bash
# 启动
docker compose up -d nginx

# 重启（修改配置后）
docker compose restart nginx

# 重载配置（不中断服务）
docker exec nginx nginx -s reload

# 测试配置语法
docker exec nginx nginx -t

# 查看日志
docker exec nginx tail -f /nginx/log/access.log
docker exec nginx tail -f /nginx/log/error.log

# 宿主机查看日志
tail -f /home/xuqinqin/develop/docker/nginx/log/access.log
```

## FPM 联动

设置 `.env` 中 `LINK_FPM=true`，构建时自动生成 `upstream php-upstream { server fpm:9000; }` 到 `/etc/nginx/conf.d/upstream.conf`，PHP 站点可直接 `fastcgi_pass php-upstream`。
