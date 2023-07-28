ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm

RUN apt-get update && apt-get install -y ca-certificates gnupg

RUN mkdir /usr/local/etc/php/pool.d/ && mkdir /www/ && mkdir -m 0755 -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&\
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update
RUN apt-get install -y libpng-dev && \
    apt-get install -y libldap2-dev && \
    apt-get install -y gdb && \
    apt-get install -y git && \
    apt-get install -y zsh && \
    apt-get install -y sudo && \
    apt-get install -y docker-ce-cli

RUN docker-php-ext-install pdo_mysql && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install gd && \
    docker-php-ext-install zip && \
    docker-php-ext-install pcntl && \
    docker-php-ext-install posix && \
    docker-php-ext-install exif && \
    docker-php-ext-install gettext && \
    docker-php-ext-install sockets && \
    docker-php-ext-install ldap

#---------------------------------------------
# Composer
#---------------------------------------------
ARG INSTALL_COMPOSER
RUN curl -s http://getcomposer.org/installer | php && \
    echo "export PATH=${PATH}:/var/www/vendor/bin" >> ~/.bashrc && \
    mv composer.phar /usr/local/bin/composer

ADD ./phpunit-7.1.5.phar /usr/local/bin/phpunit
RUN chmod 755 /usr/local/bin/phpunit

#---------------------------------------------
# Xdebug
#---------------------------------------------
ARG INSTALL_XDEBUG
RUN if [ ${INSTALL_XDEBUG} = true ]; then \
    # Install the xdebug extension
    # https://xdebug.org/docs/compat
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ] || { [ $(php -r "echo PHP_MAJOR_VERSION;") = "7" ] && { [ $(php -r "echo PHP_MINOR_VERSION;") = "4" ] || [ $(php -r "echo PHP_MINOR_VERSION;") = "3" ] ;} ;}; then \
        pecl install xdebug-3.1.1; \
    else \
        if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
            pecl install xdebug-2.5.5; \
        else \
            if [ $(php -r "echo PHP_MINOR_VERSION;") = "0" ]; then \
                pecl install xdebug-2.9.0; \
            else \
                pecl install xdebug-2.9.8; \
            fi \
        fi \
    fi && \
    ln -s /usr/local/etc/php.conf/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini \
;fi

#---------------------------------------------
# Redis
#---------------------------------------------
ARG INSTALL_REDIS
RUN if [ ${INSTALL_REDIS} = true ]; then \
    printf "\n" | pecl install -o -f redis && \
    rm -rf /tmp/pear && \
    ln -s /usr/local/etc/php.conf/redis.ini /usr/local/etc/php/conf.d/redis.ini \
;fi

#---------------------------------------------
# Swoole
#---------------------------------------------
ARG INSTALL_SWOOLE
RUN if [ ${INSTALL_SWOOLE} = true ]; then \
    if [ $(php -r "echo PHP_VERSION_ID - PHP_RELEASE_VERSION;") = "50600" ]; then \
        pecl install swoole-2.0.10; \
    elif [ $(php -r "echo PHP_VERSION_ID - PHP_RELEASE_VERSION;") = "70000" ]; then \
        pecl install swoole-4.3.5; \
    elif [ $(php -r "echo PHP_VERSION_ID - PHP_RELEASE_VERSION;") = "70100" ]; then \
        pecl install swoole-4.5.11; \
    else \
        pecl install swoole; \
    fi; \
    ln -s /usr/local/etc/php.conf/swoole.ini /usr/local/etc/php/conf.d/swoole.ini \
;fi

#---------------------------------------------
# Jieba
#---------------------------------------------
ARG INSTALL_JIEBA
RUN if [ ${INSTALL_JIEBA} = true ]; then \
    git clone https://github.com/jonnywang/phpjieba.git /opt/phpjieba && \
    cd /opt/phpjieba/cjieba && \
    make && \
    cd .. && \
    phpize && \
    ./configure && \
    make && \
    make install && \
    ln -s /usr/local/etc/php.conf/jieba.ini /usr/local/etc/php/conf.d/jieba.ini \
;fi

#---------------------------------------------
# Imagick
#---------------------------------------------
ARG INSTALL_IMAGICK
ARG IMAGICK_VERSION=latest
RUN if [ ${INSTALL_IMAGICK} = true ]; then \
    apt-get install -y libmagickwand-dev imagemagick && \
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
        cd /tmp && \
        if [ ${IMAGICK_VERSION} = "latest" ]; then \
            git clone https://github.com/Imagick/imagick; \
        else \
            git clone --branch ${IMAGICK_VERSION} https://github.com/Imagick/imagick; \
        fi && \
        cd imagick && \
        phpize && \
        ./configure && \
        make && \
        make install && \
        rm -r /tmp/imagick; \
    else \
        pecl install imagick; \
    fi && \
    php -m | grep -q 'imagick'; \
    ln -s /usr/local/etc/php.conf/imagick.ini /usr/local/etc/php/conf.d/imagick.ini \
;fi

#---------------------------------------------
# Phalcon
#---------------------------------------------
ARG INSTALL_PHALCON
ARG PHALCON_VERSION
RUN if [ ${INSTALL_PHALCON} = true ]; then \
    apt-get install -y unzip libpcre3-dev re2c automake autoconf\
    && pecl install psr \
    && curl -L -o /tmp/cphalcon.zip https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.zip \
    && unzip -d /tmp/ /tmp/cphalcon.zip \
    && cd /tmp/cphalcon-${PHALCON_VERSION}/build \
    && ./install \
    && ln -s /usr/local/etc/php.conf/phalcon.ini /usr/local/etc/php/conf.d/phalcon.ini \
    && rm -rf /tmp/cphalcon* \
;fi

ARG USER_ID
RUN useradd docker -u ${USER_ID} -g root -m && \
    echo 'docker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo '%root ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER docker
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
