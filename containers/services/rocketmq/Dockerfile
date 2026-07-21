ARG ROCKETMQ_VERSION=4.7.1
FROM apache/rocketmq:${ROCKETMQ_VERSION}

ARG HOST_UID=1000
ARG HOST_GID=984
ARG HOST_USER=docker

USER root
RUN chmod 755 /home/rocketmq \
  && groupadd -g ${HOST_GID} ${HOST_USER} \
  && useradd -u ${HOST_UID} -g ${HOST_GID} -d /home/${HOST_USER} -m -s /bin/bash ${HOST_USER} \
  && mkdir -p /home/${HOST_USER}/logs/rocketmqlogs \
  && chown -R ${HOST_USER}:${HOST_GID} /home/${HOST_USER}
USER ${HOST_USER}
