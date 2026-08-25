ARG JDK_VERSION=11
FROM eclipse-temurin:${JDK_VERSION}

RUN apt-get update && apt-get install -y --no-install-recommends \
  cmake build-essential ant \
  && wget -qO- https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/6.4.2/flyway-commandline-6.4.2-linux-x64.tar.gz | tar xvz \
  && ln -s `pwd`/flyway-6.4.2/flyway /usr/local/bin && chmod +x /usr/local/bin/flyway \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV MAVEN_HOME=/usr/local/maven \
  GRADLE_HOME=/usr/local/gradle \
  PATH=$PATH:$MAVEN_HOME/bin:$GRADLE_HOME/bin

# build opencv
COPY ./build.sh /opt
ARG BUILD_OPENCV=false
RUN if [ $BUILD_OPENCV = true ]; then cd /opt && git config --global http.postBuffer 524288000 && sh build.sh; fi

# eclipse-temurin 内置 ubuntu 用户（UID 1000），重命名复用
RUN usermod -l docker -d /home/docker -m ubuntu && \
    usermod -g root docker && \
    echo "alias java='java \$JAVA_OPTS'" >> /home/docker/.bashrc

# login shell 下 /etc/profile 会重置 PATH，此脚本确保 JDK/maven/gradle 在 PATH 中
RUN echo 'export PATH="/opt/java/openjdk/bin:/usr/local/maven/bin:/usr/local/gradle/bin:$PATH"' > /etc/profile.d/java.sh

USER docker
