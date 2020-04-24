ARG JDK_VERSION=latest
FROM openjdk:${JDK_VERSION}

ENV MAVEN_HOME /usr/local/maven
ENV PATH $PATH:$MAVEN_HOME/bin
ENV GRADLE_HOME /usr/local/gradle
ENV PATH $PATH:$GRADLE_HOME/bin

ARG USER_ID
RUN echo ${USER_ID}
RUN useradd docker -u ${USER_ID} -g root -m
USER docker