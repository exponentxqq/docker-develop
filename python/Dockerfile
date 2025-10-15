FROM tensorflow/tensorflow

RUN apt-get update && \
    apt-get install -y unzip vim git wget zsh python2.7 python3-pip libmysqlclient-dev build-essential libssl-dev libffi-dev python2-dev libreoffice poppler-utils && \
    # you can use `aws configure` to generate the default configuration \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip

ADD ./scripts/get-pip.py /home/get-pip.py
RUN python3 -m pip install --upgrade pip && \
    python2.7 /home/get-pip.py && python2.7 -m pip install --upgrade pip

RUN pip3 install \
    # 文本相似度 \
    datasketch \
    # ymal解析库 \
    pyyaml  \
    # html爬虫库 \
    requests-html \
    # google文字转语音 \
    google-cloud-texttospeech && \
    # 解析HTML和XML文档 beautifulsoup4 镜像中已存在 \
    # 阿里云oss \
    pip2 install python-dateutil==1.5

ARG USER_ID
RUN useradd docker -u ${USER_ID} -g root -m
USER docker
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
