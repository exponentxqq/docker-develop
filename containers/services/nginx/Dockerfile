ARG NGINX_VERSION
FROM nginx:${NGINX_VERSION}

COPY nginx.conf /etc/nginx/

RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*


ARG LINK_FPM=false
ARG PHP_FPM_PORT
RUN if [ ${LINK_FPM} = true ]; then \
      echo "upstream php-upstream { server fpm:${PHP_FPM_PORT}; }" > /etc/nginx/conf.d/upstream.conf; \
    fi && \
    mkdir /nginx && mkdir /nginx/log

ARG USER_ID
RUN useradd docker -u ${USER_ID} -g root -m
