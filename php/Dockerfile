ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm

RUN mkdir /usr/local/etc/php/pool.d/ && mkdir /www/

RUN apt-get update  && \
    apt-get install -y libpng-dev && \
    apt-get install -y git && \
    apt-get install -y vim && \
    apt-get install -y ps-watcher && \
    apt-get install -y net-tools && \
    apt-get install -y iputils-ping && \
    apt-get install -y gdb

RUN docker-php-ext-install pdo_mysql && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install gd && \
    docker-php-ext-install zip && \
    docker-php-ext-install pcntl && \
    docker-php-ext-install posix

RUN if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
        pecl install xdebug-2.5.5; \
    else \
        pecl install xdebug; \
    fi \
    && docker-php-ext-enable xdebug

ADD http://pecl.php.net/get/redis-4.0.0.tgz /home
RUN pecl install /home/redis-4.0.0.tgz \
    && docker-php-ext-enable redis

RUN if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
        pecl install swoole-2.0.10; \
    else \
        if [ $(php -r "echo PHP_MINOR_VERSION;") = "0" ]; then \
            pecl install swoole-2.2.0; \
        else \
            pecl install swoole; \
        fi \
    fi && \
    docker-php-ext-enable swoole \
    && php -m | grep -q 'swoole'

ADD https://getcomposer.org/composer.phar /usr/local/bin/composer
RUN chmod 755 /usr/local/bin/composer

ADD ./phpunit-7.1.5.phar /usr/local/bin/phpunit
RUN chmod 755 /usr/local/bin/phpunit

# RUN apt-get install -y node && \
#     apt-get install -y nodejs-legacy && \
#     apt-get install -y npm && \
#     npm config set registry https://registry.npm.taobao.org && \
#     npm install n -g && n stable && \
#     npm install -g yarn && \
#     npm install -g vue-cli

ENV PATH /usr/java/bin:$PATH
ENV CLASSPATH /usr/java/lib
ADD ./jdk-10.0.1_linux-x64_bin.tar.gz /opt
RUN mkdir /usr/java && cp -r /opt/jdk-10.0.1/* /usr/java/