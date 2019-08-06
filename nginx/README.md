生成开发环境下的https自签证书

1. 将ssl目录下的ssl.conf文件的DNS.1配置项改为需要配置https的域名

2. 执行generate-cert.sh，会生成local.crt和local.key文件
> 注意：脚本执行过程中会提示输入各种信息，其中Common Name项必须填当前需要设置https的站点域名，
> 可以设置为*.xxx.xxx

3. 配置site-enable目录下的web站点配置文件，增加如下配置
```$xslt
listen 443 ssl;

ssl_certificate ssl/local.crt;
ssl_certificate_key ssl/local.key;
```

4. 执行service nginx reload