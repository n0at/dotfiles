FROM ubuntu:18.04

RUN set -x \
    && sed -i.bak -e "s%http://archive.ubuntu.com/ubuntu/%http://ftp.jaist.ac.jp/pub/Linux/ubuntu/%g" /etc/apt/sources.list \
    && apt-get update -y \
    && apt-get install -y git sudo curl wget