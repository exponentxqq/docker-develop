ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm

RUN mkdir /usr/local/etc/php/pool.d/ && mkdir /www/

RUN apt-get update  && \
    apt-get install -y libpng-dev && \
    apt-get install -y gdb && \
    apt-get install -y git

RUN docker-php-ext-install pdo_mysql && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install gd && \
    docker-php-ext-install zip && \
    docker-php-ext-install pcntl && \
    docker-php-ext-install posix

#---------------------------------------------
# PHP_XDEBUG
#---------------------------------------------

ARG INSTALL_XDEBUG=false

RUN if [ ${INSTALL_XDEBUG} = true ]; then \
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
        pecl install xdebug-2.5.5; \
    else \
        pecl install xdebug; \
    fi && \
    docker-php-ext-enable xdebug \
;fi

COPY ./conf.d/xdebug.ini /usr/local/etc/php/conf.d

#---------------------------------------------
# REDIS
#---------------------------------------------

ARG INSTALL_REDIS=false

RUN if [ ${INSTALL_REDIS} = true ]; then \
    printf "\n" | pecl install -o -f redis && \
    rm -rf /tmp/pear && \
    docker-php-ext-enable redis \
;fi

#---------------------------------------------
# SWOOLE
#---------------------------------------------

ARG INSTALL_SWOOLE=false

RUN if [ ${INSTALL_SWOOLE} = true ]; then \
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
        pecl install swoole-2.0.10; \
    else \
        if [ $(php -r "echo PHP_MINOR_VERSION;") = "0" ]; then \
            pecl install swoole-2.2.0; \
        else \
            pecl install swoole; \
        fi \
    fi && \
    docker-php-ext-enable swoole && \
    php -m | grep -q 'swoole' \
;fi

#---------------------------------------------
# PYTHON2
#---------------------------------------------

ARG INSTALL_PYTHON2=false

RUN if [ ${INSTALL_PYTHON2} = true ]; then \
    apt-get-install -y python2 \
    python-dev \
    python-pip \
    python-qt4 \
;fi

#---------------------------------------------
# PYTHON3
#---------------------------------------------

ARG INSTALL_PYTHON3=false

RUN if [ ${INSTALL_PYTHON3} = true ]; then \
    apt-get install -y python3 \
    python3-dev \
    python3-pip \
    default-libmysqlclient-dev \
;fi

#---------------------------------------------
# PYTHON PACK
#---------------------------------------------

ARG INSTALL_PYTHON_PACK=false

RUN if [ ${INSTALL_PYTHON_PACK} = true ]; then \
    sed -i 's/unsigned long packet_length;/unsigned long packet_length;unsigned int reconnect;/' /usr/include/mysql/mysql.h && \
    pip install jieba \
    MySQL-python \
    opencv-python \
    image \
    hanziconv \
    lark-parser \
    torndb \
    imutils \
;fi

#---------------------------------------------
# PHP_JIEBA
#---------------------------------------------

ARG INSTALL_JIEBA=false

RUN if [ ${INSTALL_JIEBA} = true ]; then \
    git clone https://github.com/jonnywang/phpjieba.git /opt/phpjieba && \
    cd /opt/phpjieba/cjieba && \
    make && \
    cd .. && \
    phpize && \
    ./configure && \
    make && \
    make install \
;fi

COPY ./conf.d/jieba.ini /usr/local/etc/php/conf.d