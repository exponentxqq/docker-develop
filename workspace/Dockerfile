FROM ubuntu:20.04

RUN apt-get update

#---------------------------------------------
# ZSH-USER
#---------------------------------------------
RUN apt-get install -y sudo && \
    apt-get install -y wget && \
    apt-get install -y zsh && \
    apt-get install -y git && \
    apt-get install -y neovim && \
    apt-get install -y python && \
    apt-get install -y python3 && \
    apt-get install -y python-dev && \
    apt-get install -y python3-dev && \
    apt-get install -y python3-pip && \
    apt-get install -y python3-neovim && \
    apt-get install -y ranger && \
    apt-get clean

ARG USER_ID
RUN echo 'root:123456' | chpasswd &&\
    echo "%sudo ALL=(ALL:ALL) ALL" >> /etc/sudoers &&\
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "docker ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers &&\
    useradd docker -u ${USER_ID} -g root -m &&\
    groupadd docker && \
    gpasswd -a docker docker && \
    newgrp docker
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh


