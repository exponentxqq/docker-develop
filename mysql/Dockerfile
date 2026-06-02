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

RUN if command -v microdnf >/dev/null 2>&1; then \
  microdnf update -y && microdnf install -y python3 python3-pip less \
  && pip3 install mycli && microdnf clean all; \
  elif command -v apt-get >/dev/null 2>&1; then \
  apt-get update && apt-get install -y python3 python3-pip less \
  && pip3 install mycli && apt-get clean && rm -rf /var/lib/apt/lists/*; \
  fi

#####################################
# Install qpress and xtrabackup
#####################################

RUN curl -fsSL --retry 3 "https://help-static-aliyun-doc.aliyuncs.com/file-manage-files/zh-CN/20230406/flxd/qpress-11-linux-x64.tar" -o qpress.tar \
  && tar -xvf qpress.tar \
  && chmod 775 qpress \
  && cp qpress /usr/bin \
  && rm -f qpress.tar qpress

# MySQL 5.7 image is Oracle Linux 7 (has libgcrypt.so.11, libssl.so.10 natively)
# MySQL 8.0 image is Oracle Linux 9 (needs extra compat libs)
RUN ARCH=$(rpm --eval '%{_arch}') \
  && if grep -q 'VERSION="7' /etc/os-release 2>/dev/null; then \
  curl -fsSL --retry 3 "https://downloads.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.28/binary/redhat/7/x86_64/percona-xtrabackup-24-2.4.28-1.el7.x86_64.rpm" -o xtrabackup.rpm \
  && rpm -ivh --nodeps xtrabackup.rpm \
  && rm -f xtrabackup.rpm; \
  else \
  microdnf install -y cpio \
  && curl -fsSL --retry 3 "https://downloads.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.28/binary/redhat/7/x86_64/percona-xtrabackup-24-2.4.28-1.el7.x86_64.rpm" -o xtrabackup.rpm \
  && rpm -ivh --nodeps xtrabackup.rpm && rm -f xtrabackup.rpm \
  && curl -fsSL --retry 3 "https://mirrors.aliyun.com/centos-vault/7.9.2009/os/x86_64/Packages/libgcrypt-1.5.3-14.el7.x86_64.rpm" -o libgcrypt.rpm \
  && rpm2cpio libgcrypt.rpm | cpio -idm && rm -f libgcrypt.rpm \
  && curl -fsSL --retry 3 "https://mirrors.aliyun.com/centos-vault/7.9.2009/os/x86_64/Packages/openssl-libs-1.0.2k-19.el7.x86_64.rpm" -o openssl.rpm \
  && rpm2cpio openssl.rpm | cpio -idm && rm -f openssl.rpm; \
  fi

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
  echo ${TZ} > /etc/timezone && \
  chown -R mysql:root /var/lib/mysql/


CMD ["mysqld"]
