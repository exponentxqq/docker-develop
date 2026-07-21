# RocketMQ

NameServer + Broker 双容器,宿主机用户运行(uid 1000)。

## 镜像

- **镜像**: `apache/rocketmq:4.7.1`
- **容器名**: `rocketmq-namesrv` / `rocketmq-broker`
- **运行用户**: `HOST_UID:HOST_GID`(与宿主机一致,避免文件权限问题)

## 端口

| 端口 | 用途 |
|------|------|
| 9876 | NameServer(服务发现) |
| 10911 | Broker(消息收发) |

## 启动/停止

```bash
docker compose up -d rocketmq-namesrv rocketmq-broker
docker compose stop rocketmq-namesrv rocketmq-broker
```

## 验证

```bash
docker logs rocketmq-broker | tail -20
# 期望: "The broker[broker-a, 172.19.0.x:10911] boot success"
```

## 初始化

镜像内用户是 `rocketmq`(uid 3000),compose 覆盖为 `${HOST_UID}:${HOST_GID}`(uid 1000)。数据目录需 777 或 chown:

```bash
mkdir -p /data/rocketmq-4.7.1/{store,logs/namesrv,logs/broker}
chmod -R 777 /data/rocketmq-4.7.1/
```

> 不初始化会导致 Broker 因无法写入存储目录而 exit 253 且无日志。

## 数据目录

- 消息存储: `/data/rocketmq-4.7.1/store` → 容器 `/home/rocketmq/store`
- 日志: `/data/rocketmq-4.7.1/logs/*` → 容器 `/home/rocketmq/logs/*`

## Spring Boot 集成

### 依赖

```xml
<dependency>
    <groupId>org.apache.rocketmq</groupId>
    <artifactId>rocketmq-spring-boot-starter</artifactId>
    <version>2.2.0</version>
</dependency>
```

### 配置

```properties
rocketmq.name-server=127.0.0.1:9876
rocketmq.producer.group=spring-boot-producer
```

> broker 地址由 NameServer 自动返回(brokerIP1 自动检测容器 eth0 IP),宿主机从 namesrv 获取后可直接访问。

## 设计说明

- **绕过 runbroker.sh**: 直接执行 `java` 避免脚本基于宿主机 `free -m` 计算超大堆(7966M+AlwaysPreTouch)
- **-Duser.home**: 容器内无 HOST_UID 的 passwd 条目,Java `user.home` = `?`,需显式指定
- **broker.conf**: 设置 `storePathRootDir` 确保持久化数据写入挂载卷
- **Dockerfile**: `chmod 777 /home/rocketmq` 解决原镜像 HOME 目录 700 不可遍历问题
