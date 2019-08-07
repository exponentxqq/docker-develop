FROM phusion/baseimage
ARG PHP_VERSION
RUN apt-get update
RUN apt-get install -y python-software-properties && \
    add-apt-repository -y ppa:ondrej/php

RUN apt-get update

RUN apt-get install -y libpng-dev && \
    apt-get install -y php${PHP_VERSION} && \
    apt-get install -y php${PHP_VERSION}-dev && \
    apt-get install -y git && \
    apt-get install -y vim && \
    apt-get install -y ps-watcher && \
    apt-get install -y net-tools && \
    apt-get install -y iputils-ping && \
    apt-get install -y mysql-client && \
    apt-get install -y libmysqld-dev

RUN apt-get install -y php${PHP_VERSION}-curl && \
    apt-get install -y php${PHP_VERSION}-gd && \
    apt-get install -y php${PHP_VERSION}-mbstring && \
    apt-get install -y php${PHP_VERSION}-xml && \
    apt-get install -y php${PHP_VERSION}-zip && \
    apt-get install -y php${PHP_VERSION}-mysql


RUN echo "export EDITOR=vim" >> /etc/profile

ADD https://getcomposer.org/composer.phar /usr/local/bin/composer
RUN chmod 755 /usr/local/bin/composer

RUN apt-get install -y nodejs && \
    apt-get install -y npm && \
    npm config set registry https://registry.npm.taobao.org && \
    npm install n -g && n stable

ENV PATH /usr/java/bin:$PATH
ENV CLASSPATH /usr/java/lib
ADD ./jdk-10.0.1_linux-x64_bin.tar.gz /opt
RUN mkdir /usr/java && cp -r /opt/jdk-10.0.1/* /usr/java/