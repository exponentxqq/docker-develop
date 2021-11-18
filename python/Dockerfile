FROM tensorflow/tensorflow

RUN apt-get update

RUN apt-get install -y unzip vim wget zsh git python2.7 python3-pip && \
    # you can use `aws configure` to generate the default configuration
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip

RUN pip install tqdm pillow boto3 oss2 chardet pymysql w3lib openpyxl pymongo

ARG USER_ID
RUN useradd docker -u ${USER_ID} -g root -m
USER docker
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
