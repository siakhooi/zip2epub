FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y \
        language-pack-en-base \
        libegl1 \
        libfreetype6-dev \
        libgl1 \
        libopengl0 \
        libxcb-cursor0 \
        libxkbcommon-x11-0 \
        python3 \
        unzip \
        wget \
        xz-utils && \
    rm -rf /var/lib/apt/lists/* && \
    wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sh /dev/stdin install_dir=/opt/calibre

ENV PATH="/opt/calibre:${PATH}"
ENV LC_ALL=en_US.utf8
