FROM tensorflow/tensorflow

RUN apt-get update

RUN apt-get install -y unzip vim wget zsh git python2.7 python3-pip libmysqlclient-dev build-essential libssl-dev libffi-dev python2-dev mysql-client && \
    # you can use `aws configure` to generate the default configuration
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip

ADD ./scripts/get-pip.py /home/get-pip.py
ADD ./my_config.h /usr/include/mysql/my_config.h
ADD ./my_config_x86_64.h /usr/include/mysql/my_config_x86_64.h
RUN python3 -m pip install --upgrade pip && \
    pip3 install tqdm pillow boto3 oss2 chardet pymysql w3lib openpyxl pymongo && \
    python2.7 /home/get-pip.py && python2.7 -m pip install --upgrade pip && \
    pip2 install pymysql pymongo tqdm pillow chardet oss2 threadpool multiprocessing

RUN apt-get install -y libsm6 libxext6 libxrender-dev && \
    pip2 install --upgrade setuptools cryptography lxml && \
    pip2 install -U pyopenssl && \
    pip2 install --default-timeout=120  requests \
    argparse \
    jieba \
    mysql-python==1.2.5 \
    opencv-python==4.2.0.32 \
    image \
    hanziconv \
    lark-parser \
    torndb \
    imutils==0.5.4

RUN pip3 install \
    # 文本相似度
    datasketch \
    # ymal解析库
    pyyaml  \
    # html爬虫库
    requests-html \
    # google文字转语音
    google-cloud-texttospeech && \
    # 解析HTML和XML文档 beautifulsoup4 镜像中已存在
    # 阿里云oss
    pip2 install python-dateutil==1.5

ARG USER_ID
RUN useradd docker -u ${USER_ID} -g root -m
USER docker
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
