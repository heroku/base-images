FROM ubuntu-debootstrap:14.04

RUN echo 'deb http://archive.ubuntu.com/ubuntu trusty main' >/etc/apt/sources.list
RUN echo 'deb http://archive.ubuntu.com/ubuntu trusty-security main' >>/etc/apt/sources.list
RUN echo 'deb http://archive.ubuntu.com/ubuntu trusty-updates main' >>/etc/apt/sources.list
RUN echo 'deb http://archive.ubuntu.com/ubuntu trusty universe' >>/etc/apt/sources.list

RUN apt-get update

RUN apt-get install -y --force-yes \
    autoconf \
    bind9-host \
    bison \
    build-essential \
    coreutils \
    curl \
    daemontools \
    dnsutils \
    ed \
    git \
    imagemagick \
    iputils-tracepath \
    language-pack-en \
    libbz2-dev \
    libcurl4-openssl-dev \
    libevent-dev \
    libglib2.0-dev \
    libjpeg-dev \
    libmagickwand-dev \
    libmysqlclient-dev \
    libncurses5-dev \
    libpq-dev \
    libpq5 \
    libreadline6-dev \
    libssl-dev \
    libxml2-dev \
    libxslt-dev \
    netcat-openbsd \
    openssh-client \
    openssh-server \
    python \
    ruby \
    socat \
    syslinux \
    tar \
    telnet \
    zlib1g-dev \
    #

RUN apt-cache search language-pack \
    | cut -d ' ' -f 1 \
    | grep -v '^language\-pack\-\(gnome\|kde\)\-' \
    | grep -v '\-base$' \
    | xargs apt-get install -y --force-yes --no-install-recommends
