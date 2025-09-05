ARG MYSQL_VERSION=latest
ARG MYSQL_IMAGE=mysql
FROM ${MYSQL_IMAGE}:${MYSQL_VERSION}

#####################################
# Set Timezone
#####################################

ARG TZ=UTC
ENV TZ ${TZ}

#####################################
# Install mycli
#####################################

# Install Python and pip, then install mycli
RUN (yum update -y && yum install -y python3 python3-pip less && yum clean all) || \
    (microdnf update -y && microdnf install -y python3 python3-pip less && microdnf clean all) || \
    (apk update && apk add --no-cache python3 py3-pip) && \
    pip3 install mycli

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone && \
    chown -R mysql:root /var/lib/mysql/


CMD ["mysqld"]
