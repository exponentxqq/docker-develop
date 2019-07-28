FROM nginx

COPY nginx.conf /etc/nginx/

RUN echo "upstream php-upstream { server php-fpm:9000; }" > /etc/nginx/conf.d/upstream.conf \
    && rm /etc/nginx/conf.d/default.conf

RUN mkdir /www && mkdir /nginx && mkdir /nginx/log