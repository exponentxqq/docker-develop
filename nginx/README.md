静态html站
```nginx
server{
    charset utf-8;
    client_max_body_size 128M;
    listen 80;
    server_name www.march.localhost;

    root /develop/company/web/march-client/.output/public;
    index index.html index.htm;

    location ~* \.(eot|otf|ttf|woff)$ {
        add_header Access-Control-Allow-Origin *;
    }

    location / {
        try_files $uri $uri/ /index.index;
    }
}
```

php站
```nginx
server {
    charset utf-8;
    client_max_body_size 128M;
    listen 80;
    server_name www.default.localhost;

    root /develop/company/qms/branch/server/php/public;
    index index.php index.html;

    location ~* \.(eot|otf|ttf|woff)$ {
        add_header Access-Control-Allow-Origin *;
    }

    location /admin {
        try_files $uri /admin/index.html$is_args$args;
    }

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
生成开发环境下的https自签证书

1. 将ssl目录下的ssl.conf文件的DNS.1配置项改为需要配置https的域名

2. 宿主机中执行generate-cert.sh，会生成local.crt和local.key文件到ssl目录
> 注意：脚本执行过程中会提示输入各种信息，其中Common Name项必须填当前需要设置https的站点域名，
> 可以设置为*.xxx.xxx

3. 配置site-enable目录下的web站点配置文件，增加如下配置
```$xslt
listen 443 ssl;

ssl_certificate ssl/local.crt;
ssl_certificate_key ssl/local.key;
```

4. 在nginx容器中执行service nginx reload或者直接重启nginx容器
