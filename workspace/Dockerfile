ARG PHP_VERSION
FROM php:${PHP_VERSION}

RUN apt-get update

RUN apt-get install -y libpng-dev && \
    apt-get install -y git && \
    apt-get install -y vim && \
    apt-get install -y ps-watcher && \
    apt-get install -y net-tools && \
    apt-get install -y iputils-ping && \
    apt-get install -y gdb && \
    apt-get install -y default-mysql-client

RUN docker-php-ext-install pdo_mysql && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install gd && \
    docker-php-ext-install zip && \
    docker-php-ext-install pcntl && \
    docker-php-ext-install posix

ARG WORKSPACE_XDEBUG

RUN if [ ${WORKSPACE_XDEBUG} = true ]; then \
        if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
            pecl install xdebug-2.5.5; \
        else \
            pecl install xdebug; \
        fi \
        && docker-php-ext-enable xdebug; \
    fi

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

RUN apt-get install -y nodejs && \
    apt-get install -y npm && \
    npm config set registry https://registry.npm.taobao.org && \
    npm install n -g && n stable

ENV PATH /usr/java/bin:$PATH
ENV CLASSPATH /usr/java/lib
ADD ./jdk-10.0.1_linux-x64_bin.tar.gz /opt
RUN mkdir /usr/java && cp -r /opt/jdk-10.0.1/* /usr/java/

RUN apt-get install -y python2 && \
    apt-get install -y python-dev && \
    apt-get install -y python-pip && \
    apt-get install -y python3 && \
    apt-get install -y python3-dev && \
    apt-get install -y python3-pip && \
    apt-get install -y python-qt4 && \
    apt-get install -y default-libmysqlclient-dev

RUN sed -i 's/unsigned long packet_length;/unsigned long packet_length;unsigned int reconnect;/' /usr/include/mysql/mysql.h;

RUN pip install jieba && \
    pip install MySQL-python && \
    pip install opencv-python && \
    pip install image && \
    pip install hanziconv && \
    pip install lark-parser && \
    pip install torndb && \
    pip install imutils

RUN git clone https://github.com/jonnywang/phpjieba.git /opt/phpjieba && \
    cd /opt/phpjieba/cjieba && \
    make && \
    cd .. && \
    phpize && \
    ./configure && \
    make && make install

COPY ./conf.d/jieba.ini /usr/local/etc/php/conf.d