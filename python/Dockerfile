ARG CONDA_VERSION
FROM continuumio/miniconda3:${CONDA_VERSION}

# 系统依赖（Python 由 conda 提供，不再通过 apt 安装）
RUN apt-get update && \
    apt-get install -y unzip vim git wget zsh curl \
        libmariadb-dev libpq-dev build-essential libssl-dev libffi-dev \
        libreoffice poppler-utils && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && ./aws/install && \
    rm -rf awscliv2.zip aws && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 配置 conda：添加 conda-forge，创建 Python 2.7 环境
RUN conda config --add channels conda-forge && \
    conda config --set channel_priority flexible && \
    conda create -n py27 -c conda-forge python=2.7 -y && \
    conda clean -afy

# base 环境：安装通用 Python 包
RUN pip install --no-cache-dir \
    datasketch \
    pyyaml \
    requests-html \
    google-cloud-texttospeech

# py27 环境：安装 Python 2 专用包
RUN conda run -n py27 pip install python-dateutil==1.5

ARG USER_ID
RUN useradd docker -u ${USER_ID} -g root -m

USER docker
WORKDIR /home/docker

# oh-my-zsh（使用 --unattended 避免交互）
RUN wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O - | sh -s -- --unattended
