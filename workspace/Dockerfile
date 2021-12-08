FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y sudo && \
    apt-get install -y wget && \
    apt-get install -y curl &&\
    # 多线程下载
    apt-get install -y axel && \
    apt-get install -y zsh && \
    apt-get install -y git && \
    apt-get install -y neovim && \
    apt-get install -y python && \
    apt-get install -y python3 && \
    apt-get install -y python-dev && \
    apt-get install -y python3-dev && \
    apt-get install -y python3-pip && \
    apt-get install -y ranger && \
    # 网速测试
    apt-get install -y speedtest-cli && \
    # 更人性化的mysql客户端
    apt-get install -y mycli && \
    apt-get clean

ARG USER_ID
RUN echo 'root:123456' | chpasswd &&\
    echo "%sudo ALL=(ALL:ALL) ALL" >> /etc/sudoers &&\
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "docker ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers &&\
    useradd docker -u ${USER_ID} -g root -m
USER docker
RUN curl -sLf https://spacevim.org/cn/install.sh | bash && \
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh && \
    cd /home/docker && \
    wget https://raw.githubusercontent.com/mevdschee/2048.c/master/2048.c && gcc -o 2048 2048.c && mkdir -p /home/docker/bin && mv 2048 /home/docker/bin/2048 \
