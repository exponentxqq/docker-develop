# Java

JDK 11 开发容器，集成 Maven 3.6.3、Gradle 6.0.1、JavaFX 11 和 Flyway，支持远程调试和 OpenCV 编译。

## 镜像

- **基础镜像**: `openjdk:11`（通过 `JDK_VERSION` 环境变量控制）
- **构建产物**: `docker-java:11`

## 预装工具

| 工具                    | 版本   | 用途                  |
| ----------------------- | ------ | --------------------- |
| Maven                   | 3.6.3  | 构建管理和依赖解析    |
| Gradle                  | 6.0.1  | 构建自动化            |
| JavaFX                  | 11.0.2 | 桌面应用 GUI          |
| Flyway                  | 6.4.2  | 数据库迁移            |
| Ant                     | latest | 传统构建工具          |
| CMake + build-essential | —      | 本地编译（OpenCV 等） |

## 端口

| 端口      | 用途             |
| --------- | ---------------- |
| 5750      | JDWP 远程调试    |
| 8080-8089 | Web 应用端口映射 |

## 挂载

| 宿主机路径                | 容器路径                     | 说明                              |
| ------------------------- | ---------------------------- | --------------------------------- |
| `${HOST_PROJECT_PATH}`    | `${CONTAINER_PROJECT_PATH}`  | 项目代码                          |
| `${JDK_HOST_MAVEN_PATH}`  | `/usr/local/maven`           | Maven 安装目录（含 settings.xml） |
| `${JDK_HOST_GRADLE_PATH}` | `/usr/local/gradle`          | Gradle 安装目录                   |
| `${JDK_HOST_JAVAFX_PATH}` | `/usr/local/lib/javafx`      | JavaFX SDK                        |
| `cache/maven-cache`       | `/home/docker/.m2`           | Maven 本地仓库缓存                |
| `cache/gradle-cache`      | `/home/docker/.gradle`       | Gradle 缓存                       |
| `cache/javafx-cache`      | `/home/docker/.openjfx`      | JavaFX 缓存                       |
| `java/conf/`              | `/usr/local/openjdk-11/conf` | JDK 配置                          |

## 环境变量

| 变量          | 值                                     | 说明                   |
| ------------- | -------------------------------------- | ---------------------- |
| `MAVEN_HOME`  | `/usr/local/maven`                     | Maven 安装路径         |
| `GRADLE_HOME` | `/usr/local/gradle`                    | Gradle 安装路径        |
| `JAVA_OPTS`   | `-agentlib:jdwp=... -Xmx256m -Xms128m` | JVM 参数（含远程调试） |

## 远程调试

JDWP 调试端口 `5750`，JVM 启动时自动附加。IDE 中配置 Remote JVM Debug：

- Host: `127.0.0.1`
- Port: `5750`

## OpenCV 编译（可选）

设置 `.env` 中 `BUILD_OPENCV=true`，构建时自动编译 OpenCV。构建脚本位于 `java/build.sh`。

## 使用方式

```bash
# 启动
docker compose up -d java

# Maven 操作
./run.sh java "mvn clean install"
./run.sh java "mvn spring-boot:run"

# Gradle 操作
./run.sh java "gradle build"
./run.sh java "gradle bootRun"

# Flyway 迁移
./run.sh java "flyway migrate"

# 交互式 shell
docker exec -it java bash
```
