ARG PHP_VERSION
FROM phusion/baseimage

RUN apt-get update
RUN apt-get install -y python-software-properties && \
    add-apt-repository -y ppa:ondrej/php

RUN apt-get update

RUN apt-get install -y libpng-dev && \
    apt-get install -y php7.2 && \
    apt-get install -y git && \
    apt-get install -y vim && \
    apt-get install -y ps-watcher && \
    apt-get install -y net-tools && \
    apt-get install -y iputils-ping

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