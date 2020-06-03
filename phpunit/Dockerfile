ARG PHP_VERSION
FROM php:${PHP_VERSION}

RUN apt-get update &&\
    apt-get install -y libpng-dev && \
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
    docker-php-ext-install posix && \
    docker-php-ext-install exif

RUN if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
        pecl install xdebug-2.5.5; \
    else \
        pecl install xdebug; \
    fi

COPY ./conf.d/xdebug.ini /usr/local/etc/php/conf.d

RUN printf "\n" | pecl install -o -f redis && \
    rm -rf /tmp/pear && \
    docker-php-ext-enable redis

ADD ./phpunit-7.1.5.phar /usr/local/bin/phpunit
RUN chmod 755 /usr/local/bin/phpunit

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

#---------------------------------------------
# Latex
#---------------------------------------------

ARG INSTALL_LATEX=false

RUN if [ ${INSTALL_LATEX} = true ]; then\
    apt-get -y --fix-missing install dvipng texlive \
;fi

RUN apt-get -y install imagemagick libmagick++-dev && \
    pecl install imagick