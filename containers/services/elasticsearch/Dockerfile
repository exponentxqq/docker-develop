# 与公司 dockerfiles/elastic/Dockerfile 同版本（7.17.3）+ IK 分词插件
# 镜像仓库通过 ELASTICSEARCH_IMAGE 参数化（同 mysql 的 MYSQL_IMAGE 先例）：
#   公司用 docker.elastic.co/elasticsearch/elasticsearch，本机网络对该域不稳定，默认走 Docker Hub 官方同版本镜像
ARG ELASTICSEARCH_IMAGE=elasticsearch
ARG ELASTICSEARCH_VERSION=7.17.3
FROM ${ELASTICSEARCH_IMAGE}:${ELASTICSEARCH_VERSION}

# IK 分词器（阿里云 OSS 镜像源，插件版本须与 ES 版本完全一致）
ARG ELASTICSEARCH_VERSION
RUN bin/elasticsearch-plugin install --batch https://open-oss.oss-cn-shanghai.aliyuncs.com/elasticsearch-analysis-ik-${ELASTICSEARCH_VERSION}.zip
