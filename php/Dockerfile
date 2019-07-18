FROM php:7.1-fpm

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

RUN curl -fsSL 'https://xdebug.org/files/xdebug-2.6.0.tgz' -o xdebug.tar.gz \
    && mkdir -p xdebug \
    && tar -xf xdebug.tar.gz -C xdebug --strip-components=1 \
    && rm xdebug.tar.gz \
    && ( \
    cd xdebug \
    && phpize \
    && ./configure --enable-xdebug \
    && make -j$(nproc) \
    && make install \
    ) \
    && rm -r xdebug \
&& docker-php-ext-enable xdebug

ADD http://pecl.php.net/get/redis-4.0.0.tgz /home
RUN pecl install /home/redis-4.0.0.tgz \
    && docker-php-ext-enable redis
RUN pecl install swoole \
    && docker-php-ext-enable swoole

ADD https://getcomposer.org/composer.phar /usr/local/bin/composer
RUN chmod 755 /usr/local/bin/composer

ADD ./phpunit-7.1.5.phar /usr/local/bin/phpunit
RUN chmod 755 /usr/local/bin/phpunit

RUN apt-get install -y node && \
    apt-get install -y nodejs-legacy && \
    apt-get install -y npm && \
    npm config set registry https://registry.npm.taobao.org && \
    npm install n -g && n stable && \
    npm install -g yarn && \
    npm install -g vue-cli

ENV PATH /usr/java/bin:$PATH
ENV CLASSPATH /usr/java/lib
ADD ./jdk-10.0.1_linux-x64_bin.tar.gz /opt
RUN mkdir /usr/java && cp -r /opt/jdk-10.0.1/* /usr/java/