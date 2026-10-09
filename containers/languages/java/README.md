# Java

多 JDK（11/17/21）Java 开发容器，基于 Ubuntu 26.04 apt 安装，默认 JDK 17。

## 镜像

- **基础镜像**: `ubuntu:26.04`
- **JDK**: `openjdk-11-jdk-headless` / `openjdk-17-jdk-headless` / `openjdk-21-jdk-headless`（`/usr/lib/jvm/*`）
- **构建工具**: `maven`（apt）；gradle 由项目 wrapper（`./gradlew`）提供
- **镜像 tag**: `docker-java:${JAVA_UBUNTU_VERSION}`

## 版本自适应

- **Gradle 项目**：`build.gradle` 声明 `java.toolchains`，gradle 自动探测 `/usr/lib/jvm/*` 中已安装的 JDK 完成编译版本切换
- **Maven 项目**：使用项目根 `./mvnw`（wrapper），或经 `bin/mvn` 包装使用容器内 maven
- **默认版本**：未声明时 `java` 命令为 17（`update-alternatives` 默认）

## 预装工具

| 工具   | 版本      | 用途           |
| ------ | --------- | -------------- |
| JDK    | 11/17/21  | 项目 JDK       |
| Maven  | apt 版本  | 构建管理       |

## 端口

| 端口      | 用途                                                 |
| --------- | ---------------------------------------------------- |
| 8080-8089 | Web 应用端口映射（dev profile 本地应用段，默认 8080） |
| 6666      | management 端点（/shutdown 等）                      |

## 挂载

| 宿主机路径             | 容器路径                 | 说明               |
| ---------------------- | ------------------------ | ------------------ |
| `${HOST_PROJECT_PATH}` | `${HOST_PROJECT_PATH}`   | 项目代码（同路径） |
| `${HOST_HOME}/.m2`     | `/home/docker/.m2`       | Maven 本地仓库（与宿主 IDEA 共享） |
| `${HOST_HOME}/.gradle` | `/home/docker/.gradle`   | Gradle 缓存（与宿主 IDEA 共享）    |

## 使用方式

```bash
# 启动
docker compose up -d java

# 宿主包装（在任意目录）：mvn 走容器；java 无宿主包装（宿主裸 java 为宿主 JDK，供 nvim jdtls/conform）
bin/mvn -v

# 在项目目录执行构建（wrapper）
./run.sh java "cd /path/to/project && ./gradlew build"
./run.sh java "cd /path/to/project && ./mvnw clean install"

# dsh 容器会话内：java/mvn 均为容器包装（java 包装内置镜像 /usr/local/bin/java）
java -version && mvn -v
```

## 配置变量（.env）

| 变量                  | 默认值  | 说明               |
| --------------------- | ------- | ------------------ |
| `JAVA_UBUNTU_VERSION` | `26.04` | 基础镜像 ubuntu 版本 |
