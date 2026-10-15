# Elasticsearch

Elasticsearch 搜索/分析引擎容器，（7.17.3 + IK 中文分词插件），单节点 + 基本认证，数据持久化到宿主 `/data`。

## 镜像

- **基础镜像**: `${ELASTICSEARCH_IMAGE}:${ELASTICSEARCH_VERSION}`（默认 `elasticsearch:7.17.3`）
- **构建产物**: `docker-elasticsearch:7.17.3`
- **分词插件**: `analysis-ik`（IK 中文分词器，与公司同款阿里云 OSS 镜像地址；插件版本随 `ELASTICSEARCH_VERSION` 自动跟随）

> **镜像仓库为何默认走 Docker Hub**：公司 Dockerfile 用 `docker.elastic.co/elasticsearch/elasticsearch`，但该域在国内网络不稳定（实测 TLS 连接被重置，大层无法拉取）。Docker Hub 的 `elasticsearch:7.17.3` 为 Elastic 官方同版本发布产物（2022-04-21 构建，amd64/arm64），故默认走 Hub；需完全对齐公司 registry 时改 `.env` 的 `ELASTICSEARCH_IMAGE=docker.elastic.co/elasticsearch/elasticsearch` 即可（同 `MYSQL_IMAGE` 先例）。

## 端口

| 端口 | 用途                                                             |
| ---- | ---------------------------------------------------------------- |
| 9200 | HTTP REST API，映射到宿主机 `${ELASTICSEARCH_PORT}`（默认 9200） |
| 9300 | transport 端口，仅在 `backend` 网络内可用，不对宿主发布          |

## 挂载

| 宿主机路径                        | 容器路径                        | 说明                            |
| --------------------------------- | ------------------------------- | ------------------------------- |
| `${ELASTICSEARCH_HOST_DATA_PATH}` | `/usr/share/elasticsearch/data` | 数据持久化（属主须为 uid 1000） |

## 环境变量

| 变量                           | 默认值                       | 说明                                                               |
| ------------------------------ | ---------------------------- | ------------------------------------------------------------------ |
| `ELASTICSEARCH_IMAGE`          | `elasticsearch`              | 镜像仓库（公司用 `docker.elastic.co/elasticsearch/elasticsearch`） |
| `ELASTICSEARCH_VERSION`        | `7.17.3`                     | 与公司版本保持一致，升级只改此项（IK 插件版本自动跟随）            |
| `ELASTICSEARCH_PASSWORD`       | `123456`                     | `elastic` 用户密码（本地默认；公司 dev 环境用 `es@fyzs!`）          |
| `ELASTICSEARCH_PORT`           | `9200`                       | 宿主 HTTP 端口                                                     |
| `ELASTICSEARCH_HOST_DATA_PATH` | `/data/elasticsearch-7.17.3` | 数据目录                                                           |
| `ELASTICSEARCH_JAVA_OPTS`      | `-Xms512m -Xmx512m`          | JVM 堆内存（建议不超过容器内存上限的一半；含空格须加引号）         |
| `ELASTICSEARCH_MEM_LIMIT`      | `1g`                         | 容器内存上限                                                       |

## 安全配置

与公司 dev 环境同构：`discovery.type=single-node` + `xpack.security.enabled=true` + 基本认证，**HTTP 无 TLS**（公司 dev 环境即 `scheme: http` + 账号密码）。因此所有 REST 请求都需带 `-u elastic:<密码>`；transport 层 TLS 未启用的告警属预期，无需处理。

## 兼容性：cgroup v2 宿主上的启动失败（已内置修复）

ES 7.17.3 镜像自带 **JDK 18 (Temurin 18+36)**，在 **cgroup v2 宿主**（本机 Docker: `Cgroup Version: 2` + 新内核）上，JDK 的 cgroup 探测会抛 NPE 而无法启动：

```
Exception in thread "main" java.lang.NullPointerException:
  Cannot invoke "jdk.internal.platform.CgroupInfo.getMountPoint()" because "anyController" is null
 at jdk.internal.platform.cgroupv2.CgroupV2Subsystem.getInstance(CgroupV2Subsystem.java:80)
 at org.elasticsearch.tools.launchers.JvmOptionsParser.main(JvmOptionsParser.java:86)
```

关键点：崩溃发生在 `bin/elasticsearch` 的**工具 JVM**（`JvmOptionsParser`），该 JVM 的启动命令（脚本第 60 行）**只传 `$XSHARE`，不读 `ES_JAVA_OPTS`**，所以仅设置 `ES_JAVA_OPTS="-XX:-UseContainerSupport"` 无效；`--cgroupns=host` 也无效。本服务在 compose 里固定注入：

```yaml
- JDK_JAVA_OPTIONS=-XX:-UseContainerSupport
```

`JDK_JAVA_OPTIONS` 会被**所有** java 进程读取（含工具 JVM），故可绕过该 NPE。因堆内存由 `ES_JAVA_OPTS` 显式指定，失去容器内存自动探测对开发环境无影响。日志中出现 `NOTE: Picked up JDK_JAVA_OPTIONS` 属预期。

> 上游同类问题：[mastodon#33635](https://github.com/mastodon/mastodon/issues/33635)（es 7.17.4 与新版内核不兼容）、[temporalio/helm-charts#651](https://github.com/temporalio/helm-charts/issues/651)（7.17.3 无法启动）。若日后把 `ELASTICSEARCH_VERSION` 升到自带新 JDK 的版本，本项可移除。

## 初始化

数据目录须由 uid 1000（镜像内 `elasticsearch` 用户）可写，否则容器启动报 `AccessDeniedException`：

```bash
# 宿主机执行（docker daemon 自动创建的目录是 root:root 755，会因无写权限启动失败）
sudo mkdir -p /data/elasticsearch-7.17.3
sudo chown -R 1000:1000 /data/elasticsearch-7.17.3
```

宿主内核参数需满足 ES 要求（`vm.max_map_count ≥ 262144`）：

```bash
sysctl vm.max_map_count    # 不足时：sudo sysctl -w vm.max_map_count=262144 并写入 /etc/sysctl.d/
```

## 使用方式

```bash
# 构建并启动（构建期从阿里云 OSS 下载 IK 插件）
docker compose build elasticsearch
docker compose up -d elasticsearch

# 健康检查（宿主）
curl -u elastic:'123456' http://127.0.0.1:9200
curl -u elastic:'123456' http://127.0.0.1:9200/_cluster/health

# 进入容器执行命令（run.sh 会自动确保容器运行）
./run.sh elasticsearch "curl -s -u elastic:'123456' localhost:9200"
docker exec -it elasticsearch bash

# 应用容器内连接（backend 网络，与公司 dev 配置同构：scheme http + 账号密码）
curl -u elastic:'123456' http://elasticsearch:9200
```

## IK 分词验证

```bash
curl -u elastic:'123456' -H 'Content-Type: application/json' \
  -X GET "http://127.0.0.1:9200/_analyze" \
  -d '{"analyzer":"ik_max_word","text":"中华人民共和国"}'
```

返回按 `ik_max_word` 切分的 token 即插件生效。索引 mapping 中可直接使用 `ik_max_word` / `ik_smart` 分析器。

## 与公司保持一致

- **版本锚点**：公司 `dockerfiles/elastic/Dockerfile` = `elasticsearch:7.17.3` + `elasticsearch-analysis-ik-7.17.3.zip`（本仓库 Dockerfile 与该公司文件同构）
- **升级方式**：公司升级时同步修改 `.env` 的 `ELASTICSEARCH_VERSION`，IK 插件地址按同版本拼接，Dockerfile 无需改动
- **应用连接参数**（公司 `fyzs-center` 用 7.x `RestHighLevelClient`）：`ip=elasticsearch:9200`、`username=elastic`、`scheme=http`；密码本地为 `123456`，如需与公司 dev 完全一致就改 `.env` 的 `ELASTICSEARCH_PASSWORD=es@fyzs!` 并 force-recreate

## 注意事项

- 修改 `ELASTICSEARCH_PASSWORD` 后需 `docker compose up -d --force-recreate elasticsearch` 才生效（bootstrap password 语义）
- 端口 9200 被占用时改 `.env` 的 `ELASTICSEARCH_PORT`
- 单节点集群 + 索引默认副本数 1 时，副本分片无法分配，集群/索引健康度为 **yellow**（无副本可分配，非故障）；要看到 green 需建索引时设 `"number_of_replicas": 0`
- 若需挂载自定义 `elasticsearch.yml`，注意单文件挂载会覆盖镜像内同名文件
