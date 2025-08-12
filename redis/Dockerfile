ARG REDIS_VERSION=latest
FROM redis:${REDIS_VERSION}

RUN mkdir -p /usr/local/etc/redis
COPY redis.conf /usr/local/etc/redis/redis.conf

CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]