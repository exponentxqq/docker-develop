ARG JDK_VERSION=latest
FROM openjdk:${JDK_VERSION}

RUN wget -qO- https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/6.4.2/flyway-commandline-6.4.2-linux-x64.tar.gz | tar xvz && \
    ln -s `pwd`/flyway-6.4.2/flyway /usr/local/bin &&\
    chmod +x /usr/local/bin/flyway

RUN apt-get update && \
    apt-get install -y cmake build-essential ant

ENV MAVEN_HOME /usr/local/maven
ENV PATH $PATH:$MAVEN_HOME/bin
ENV GRADLE_HOME /usr/local/gradle
ENV PATH $PATH:$GRADLE_HOME/bin

# build opencv
COPY ./build.sh /opt
RUN cd /opt && git config --global http.postBuffer 524288000 && sh build.sh

ARG USER_ID
RUN echo ${USER_ID}
RUN useradd docker -u ${USER_ID} -g root -m
USER docker