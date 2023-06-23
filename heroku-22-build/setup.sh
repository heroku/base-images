#!/usr/bin/env bash

set -euo pipefail

# Redirect stderr to stdout since tracing/apt-get/dpkg spam it for things that aren't errors.
exec 2>&1
set -x

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    bison \
    build-essential \
    bzr \
    cmake \
    gettext \
    git \
    jq \
    libacl1-dev \
    libapt-pkg-dev \
    libargon2-dev \
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
    libheif-dev \
    libicu-dev \
    libidn11-dev \
    libjpeg-dev \
    libkeyutils-dev \
    libkmod-dev \
    libkrb5-dev \
    libldap2-dev \
    liblz4-dev \
    liblzf-dev \
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
    libpq-dev=15.1-1.pgdg22.04+1 \
    librabbitmq-dev \
    libreadline-dev \
    librtmp-dev \
    libseccomp-dev \
    libselinux1-dev \
    libsemanage-dev \
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
    libzstd-dev \
    mercurial \
    patchelf \
    python3-dev \
    zlib1g-dev \

rm -rf /root/*
rm -rf /tmp/*
rm -rf /var/cache/apt/archives/*.deb
rm -rf /var/lib/apt/lists/*
