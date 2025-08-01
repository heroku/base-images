#!/usr/bin/env bash

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

packages=(
  autoconf
  automake
  bison
  build-essential # Includes gcc, g++, make, patch, libc6-dev etc.
  cmake
  gettext # Internationalization utils used by Django, Rails etc.
  git
  libargon2-dev
  libbsd-dev
  libbz2-dev
  libcairo2-dev
  libcurl4-openssl-dev
  libev-dev
  libevent-dev
  libexif-dev
  libffi-dev
  libgd-dev
  libgdbm-dev
  libgnutls28-dev
  libheif-dev
  libicu-dev
  libidn-dev
  libjpeg-dev
  libkrb5-dev
  libldap-dev
  liblz4-dev
  liblzf-dev
  libmagic-dev
  libmagickwand-dev
  libmemcached-dev
  libmysqlclient-dev
  libonig-dev
  libpq-dev
  librabbitmq-dev
  librtmp-dev
  libsodium-dev
  libssl-dev
  libtool
  libuv1-dev
  libwrap0-dev
  libxml2-dev
  libxslt-dev
  libyaml-dev
  libzip-dev
  libzstd-dev
  patchelf
  python3 # Often needed during the building of non-Python apps. e.g. For Node.js packages that use node-gyp.
  zlib1g-dev
)

apt-get update --error-on=any
apt-get install -y --no-install-recommends "${packages[@]}"

rm -rf /root/*
rm -rf /tmp/*
rm -rf /var/cache/apt/archives/*.deb
rm -rf /var/lib/apt/lists/*
