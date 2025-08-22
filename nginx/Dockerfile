ARG NGINX_VERSION
FROM nginx:${NGINX_VERSION}

COPY nginx.conf /etc/nginx/

RUN apt-get update && \
    apt-get install -y curl


ARG PHP_FPM_PORT
RUN echo "upstream php-upstream { server fpm:${PHP_FPM_PORT}; }" > /etc/nginx/conf.d/upstream.conf && \
    mkdir /nginx && mkdir /nginx/log
