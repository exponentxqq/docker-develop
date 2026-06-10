ARG CONDA_VERSION
FROM continuumio/miniconda3:${CONDA_VERSION}

# 系统依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        unzip vim git wget zsh curl \
        build-essential libssl-dev libffi-dev \
        libmariadb-dev libpq-dev \
        libreoffice poppler-utils \
        libopenblas-dev liblapack-dev \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip && ./aws/install \
    && rm -rf awscliv2.zip aws \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# conda：配置 conda-forge channel
RUN conda config --add channels conda-forge \
    && conda config --set channel_priority flexible \
    && conda clean -afy

# uv：独立二进制安装（多阶段 COPY）
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# 用户
ARG USER_ID
RUN useradd docker -u ${USER_ID} -g root -m && \
    mkdir -p /home/docker/.cache /home/docker/.conda && \
    chown -R docker:root /home/docker

USER docker
WORKDIR /home/docker
