#!/bin/bash

exec 2>&1
set -e
set -x

apt-get update
apt-get install -y --force-yes --no-install-recommends \
    autoconf \
    automake \
    bison \
    build-essential \
    bzr \
    cmake \
    gettext \
    git \
    libacl1-dev \
    libapt-pkg-dev \
    libargon2-0-dev \
    libattr1-dev \
    libaudit-dev \
    libbsd-dev \
    libbz2-dev \
    libc-client2007e-dev \
    libcairo2-dev \
    libcap-dev \
    libcurl4-openssl-dev \
    libdb-dev \
    libev-dev \
    libevent-dev \
    libexif-dev \
    libffi-dev \
    libgcrypt20-dev \
    libgd-dev \
    libgdbm-dev \
    libgeoip-dev \
    libglib2.0-dev \
    libgnutls28-dev \
    libgs-dev \
    libicu-dev \
    libidn11-dev \
    libjpeg-dev \
    libkeyutils-dev \
    libkmod-dev \
    libkrb5-dev \
    libldap2-dev \
    liblz4-dev \
    libmagic-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libmemcached-dev \
    libmysqlclient-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libnetpbm10-dev \
    libonig-dev \
    libpam0g-dev \
    libpopt-dev \
    libpq-dev \
    librabbitmq-dev \
    libreadline-dev \
    librtmp-dev \
    libseccomp-dev \
    libselinux1-dev \
    libsemanage1-dev \
    libsodium-dev \
    libssl-dev \
    libsystemd-dev \
    libtool \
    libudev-dev \
    libuv1-dev \
    libwrap0-dev \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev \
    libzip-dev \
    mercurial \
    postgresql-server-dev-12 \
    python-dev \
    ruby-dev \
    zlib1g-dev \

cd /
rm -rf /root/*
rm -rf /tmp/*
rm -rf /var/cache/apt/archives/*.deb
