# Java

JDK/Maven/Gradle 版本自适应的 Java 开发容器（mise 版本管理），集成 Flyway、远程调试和 OpenCV 编译。

## 镜像

- **基础镜像**: `debian:bookworm-slim`
- **版本管理器**: [mise](https://mise.jdx.dev/)（Rust 实现，shim 模式，与 node 容器的 volta 同构）
- **构建产物**: `docker-java:mise`

## 版本管理（核心特性）

每个项目通过项目根目录的 `.mise.toml` 声明工具版本，进入项目目录后 `java`/`mvn`/`gradle` 自动切换到对应版本：

```toml
# 项目根目录 .mise.toml
[tools]
java = "17"
maven = "3.9"
gradle = "8"
```

未声明版本的项目回退到镜像全局默认（build 时设置）：`java 11` + `maven 3.6.3` + `gradle 6.0.1`。

### 新增版本

```bash
./run.sh java "mise install java@21"
./run.sh java "mise install maven@3.9"
./run.sh java "mise install gradle@8.14"
```

安装到 named volume `mise-cache`，重建容器/镜像后保留。

### 修改默认版本

```bash
./run.sh java "mise use --global java@17 maven@3.9 gradle@8"
```

## 预装工具

| 工具         | 版本                        | 用途               |
| ------------ | --------------------------- | ------------------ |
| JDK (Temurin) | 11.0.2、17.0.2              | 项目 JDK           |
| Maven        | 3.6.3、3.9.16               | 构建管理和依赖解析 |
| Gradle       | 6.0.1、8.14.5               | 构建自动化         |
| Flyway       | 6.4.2                       | 数据库迁移         |
| Ant          | latest                      | 传统构建工具       |
| CMake + build-essential | —            | 本地编译（OpenCV 等） |

## 端口

| 端口        | 用途             |
| ----------- | ---------------- |
| 5750        | JDWP 远程调试    |
| 8081-8089   | Web 应用端口映射（8080 让位宿主服务） |

## 挂载

| 宿主机路径              | 容器路径                       | 说明                     |
| ----------------------- | ------------------------------ | ------------------------ |
| `${HOST_PROJECT_PATH}`  | `${HOST_PROJECT_PATH}`         | 项目代码                 |
| `mise-cache` (named volume) | `/home/docker/.local/share/mise` | mise 工具安装（持久）   |
| `cache/maven-cache`     | `/home/docker/.m2`             | Maven 本地仓库缓存       |
| `cache/gradle-cache`    | `/home/docker/.gradle`         | Gradle 缓存              |

## 环境变量

| 变量        | 值                                      | 说明                   |
| ----------- | --------------------------------------- | ---------------------- |
| `JAVA_OPTS` | `-agentlib:jdwp=... -Xmx256m -Xms128m`  | JVM 参数（含远程调试） |

> `JAVA_OPTS` 由 compose 注入容器进程环境，Maven/Gradle 及 Java 进程会继承。注意：`./run.sh java "echo $JAVA_OPTS"` 里 `$JAVA_OPTS` 会被宿主 shell 展开为空，需用 `printenv JAVA_OPTS` 或单引号。

## 远程调试

JDWP 调试端口 `5750`，JVM 启动时自动附加（经 `JAVA_OPTS`）。IDE 中配置 Remote JVM Debug：

- Host: `127.0.0.1`
- Port: `5750`

## OpenCV 编译（可选）

设置 `.env` 中 `BUILD_OPENCV=true`，构建时自动编译 OpenCV。构建脚本位于 `java/build.sh`。

## 使用方式

```bash
# 启动
docker compose up -d java

# 在项目目录（有 .mise.toml）执行，自动使用项目声明的版本
./run.sh java "cd /path/to/project && mvn clean install"
./run.sh java "cd /path/to/project && gradle build"

# 交互式 shell（mise 自动激活）
docker exec -it java bash
```

## 配置变量（.env）

| 变量             | 默认值      | 说明                         |
| ---------------- | ----------- | ---------------------------- |
| `MISE_VERSION`   | `2026.8.12` | mise 版本（GitHub release）  |
| `BUILD_OPENCV`   | `false`     | 构建时是否编译 OpenCV        |
