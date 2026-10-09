# Java 开发容器：ubuntu apt 多 JDK（11/17/21），版本自适应由项目 gradle toolchains
# （自动探测 /usr/lib/jvm/*）与 ./mvnw wrapper 完成；不装 gradle（项目自带 wrapper）
ARG JAVA_UBUNTU_VERSION=26.04
FROM ubuntu:${JAVA_UBUNTU_VERSION}

# openjdk 11/17 位于 universe 仓库（ubuntu 官方镜像 sources 默认启用 universe）
# tzdata：TZ=Asia/Shanghai 依赖系统时区库；缺失时 glibc 静默回退 UTC（JVM 自带 tzdb 不受影响，
# 故仅表现为容器内 date/脚本日志时间错误，排查成本高）
RUN apt-get update && apt-get install -y --no-install-recommends \
  openjdk-11-jdk-headless openjdk-17-jdk-headless openjdk-21-jdk-headless \
  maven git curl wget ca-certificates tzdata \
  && rm -rf /var/lib/apt/lists/*

# 默认 JDK 17（对齐宿主现状）
RUN update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java && \
    update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac

ARG HOST_UID HOST_GID HOST_USER
# ubuntu 官方镜像预置 uid 1000 的 ubuntu 用户，与宿主 UID 冲突，先移除（与 dsh 容器一致）
RUN userdel -r ubuntu 2>/dev/null || true; \
  groupadd -g ${HOST_GID} docker && \
  useradd -m -u ${HOST_UID} -g ${HOST_GID} -s /bin/bash docker

USER docker
WORKDIR /home/docker
