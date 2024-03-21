#!/usr/bin/env bash

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

packages=(
  autoconf
  automake
  bison
  # Includes gcc, g++, make, patch, libc6-dev etc.
  build-essential
  cmake
  gettext
  git
  jq
  libacl1-dev
  libapt-pkg-dev
  libargon2-dev
  libattr1-dev
  libaudit-dev
  libbsd-dev
  libbz2-dev
  libc-client2007e-dev
  libcairo2-dev
  libcap-dev
  libcurl4-openssl-dev
  libdb-dev
  libev-dev
  libevent-dev
  libexif-dev
  libffi-dev
  libgcrypt20-dev
  libgd-dev
  libgdbm-dev
  libgeoip-dev
  libglib2.0-dev
  libgnutls28-dev
  libheif-dev
  libicu-dev
  libidn11-dev
  libjpeg-dev
  libkeyutils-dev
  libkmod-dev
  libkrb5-dev
  libldap2-dev
  liblz4-dev
  liblzf-dev
  libmagic-dev
  libmagickwand-dev
  libmcrypt-dev
  libmemcached-dev
  libmysqlclient-dev
  libncurses5-dev
  libncursesw5-dev
  libnetpbm10-dev
  libonig-dev
  libpam0g-dev
  libpopt-dev
  libpq-dev
  librabbitmq-dev
  libreadline-dev
  librtmp-dev
  libseccomp-dev
  libselinux1-dev
  libsemanage-dev
  libsodium-dev
  libssl-dev
  libsystemd-dev
  libtool
  libudev-dev
  libuv1-dev
  libwrap0-dev
  libxml2-dev
  libxslt-dev
  libyaml-dev
  libzip-dev
  libzstd-dev
  patchelf
  # Python is often needed during the build for non-Python apps, which aren't using the
  # Python buildpack. e.g. Node.js packages that use node-gyp require Python during install.
  python3
  zlib1g-dev
)

apt-get update --error-on=any
apt-get install -y --no-install-recommends "${packages[@]}"

rm -rf /root/*
rm -rf /tmp/*
rm -rf /var/cache/apt/archives/*.deb
rm -rf /var/lib/apt/lists/*
