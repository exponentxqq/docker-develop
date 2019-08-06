FROM nginx

COPY nginx.conf /etc/nginx/

RUN apt-get update

RUN apt-get install -y curl

ARG PHP_FPM_PORT
RUN echo "upstream php-upstream { server php-fpm:${PHP_FPM_PORT}; }" > /etc/nginx/conf.d/upstream.conf

RUN mkdir /nginx && mkdir /nginx/log