FROM phusion/baseimage

#---------------------------------------------
# PHP
#---------------------------------------------
ARG PHP_VERSION

# Add the "PHP 7" ppa
RUN apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:ondrej/php

RUN apt-get update && \
    apt-get install -y php${PHP_VERSION} \
        php${PHP_VERSION}-dev \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-mysql \
        libpng-dev \
        iputils-ping \
        mysql-client

ARG INSTALL_MONGO=false
RUN if [ ${INSTALL_MONGO} = true ]; then \
    apt-get install -y mongodb \
        php${PHP_VERSION}-mongo \
;fi

#---------------------------------------------
# GIT
#---------------------------------------------

ARG INSTALL_GIT=false

RUN if [ ${INSTALL_GIT} = true ]; then \
    apt-get install -y git git-flow \
;fi

#---------------------------------------------
# VIM
#---------------------------------------------

ARG INSTALL_VIM=false

RUN if [ ${INSTALL_VIM} = true ]; then \
    apt-get install -y vim && \
    echo "export EDITOR=vim" >> /etc/profile \
;fi

#---------------------------------------------
# NET-TOOLS
#---------------------------------------------

ARG INSTALL_NETTOOLS=false

RUN if [ ${INSTALL_NETTOOLS} = true ]; then \
    apt-get install -y net-tools \
;fi

#---------------------------------------------
# PS-WATCHER
#---------------------------------------------

ARG INSTALL_PS_WATCHER=false

RUN if [ ${INSTALL_PS_WATCHER} = true ]; then \
    apt-get install -y ps-watcher \
;fi

#---------------------------------------------
# COMPOSER
#---------------------------------------------

ARG INSTALL_COMPOSER=false

RUN if [ ${INSTALL_COMPOSER} = true ]; then \
    curl -s http://getcomposer.org/installer | php && \
    echo "export PATH=${PATH}:/var/www/vendor/bin" >> ~/.bashrc && \
    mv composer.phar /usr/local/bin/composer \
;fi

#---------------------------------------------
# NODE
#---------------------------------------------

ARG INSTALL_NODE=false

RUN if [ ${INSTALL_NODE} = true ]; then \
    apt-get install -y nodejs && \
    apt-get install -y npm && \
    npm config set registry https://registry.npm.taobao.org && \
    npm install n -g && n stable && \
    npm i npm -g && \
    npm i docsify-cli -g && \
    npm i -g umi \
;fi

RUN apt-get install -y wget zsh && \
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh

#---------------------------------------------
# JDK
#---------------------------------------------

ARG INSTALL_JDK=false

ADD ./jdk-10.0.1_linux-x64_bin.tar.gz /opt

RUN if [ ${INSTALL_JDK} = true ]; then \
    mkdir /usr/java && cp -r /opt/jdk-10.0.1/* /usr/java/ \
;fi

RUN PATH=$PATH:/usr/java/bin
ENV CLASSPATH /usr/java/lib

RUN apt-get clean