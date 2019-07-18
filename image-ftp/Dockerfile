FROM ubuntu

RUN apt-get update
RUN apt-get install -y vsftpd
RUN apt-get install -y nfs-kernel-server runit inotify-tools -qq
RUN apt-get install -y vim

image-ftp:
    build: ./image-ftp
    container_name: image-ftp
    ports:
      - "21:21"
      - "20100-20200:20100-20200"
      - "30000-30200:30000-30200"
    volumes:
      - ./image-ftp/data/:/home/image-ftp/
      - ./image-ftp/vsftpd.conf:/etc/vsftpd.conf
    networks:
      - develop