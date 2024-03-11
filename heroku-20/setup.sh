#!/usr/bin/env bash

set -euo pipefail

# Redirect stderr to stdout since tracing/apt-get/dpkg spam it for things that aren't errors.
exec 2>&1
set -x

export DEBIAN_FRONTEND=noninteractive

# The default sources list minus backports, restricted and multiverse.
cat >/etc/apt/sources.list <<EOF
deb http://archive.ubuntu.com/ubuntu/ focal main universe
deb http://archive.ubuntu.com/ubuntu/ focal-security main universe
deb http://archive.ubuntu.com/ubuntu/ focal-updates main universe
EOF

apt-get update --error-on=any

# Required by apt-key and does not exist in the base image on newer Ubuntu.
apt-get install -y --no-install-recommends gnupg

# In order to support all features offered by Heroku Postgres, we need newer postgresql-client
# than is available in the Ubuntu repository, so use the upstream APT repository instead:
# https://wiki.postgresql.org/wiki/Apt
cat >>/etc/apt/sources.list <<EOF
deb http://apt.postgresql.org/pub/repos/apt/ focal-pgdg main
EOF
apt-key add /build/postgresql-ACCC4CF8.asc

apt-get update --error-on=any
apt-get upgrade -y
apt-get install -y --no-install-recommends \
    apt-transport-https \
    apt-utils \
    bind9-host \
    bzip2 \
    coreutils \
    curl \
    dnsutils \
    ed \
    file \
    fontconfig \
    gcc \
    geoip-database \
    gettext-base \
    ghostscript \
    gir1.2-harfbuzz-0.0 \
    git \
    gsfonts \
    imagemagick \
    iproute2 \
    iputils-tracepath \
    language-pack-en \
    less \
    libaom0 \
    libargon2-1 \
    libass9 \
    libc-client2007e \
    libc6-dev \
    libcairo2 \
    libcroco3 \
    libcurl4 \
    libdatrie1 \
    libev4 \
    libevent-2.1-7 \
    libevent-core-2.1-7 \
    libevent-extra-2.1-7 \
    libevent-openssl-2.1-7 \
    libevent-pthreads-2.1-7 \
    libexif12 \
    libfreetype6 \
    libfribidi0 \
    libgd3 \
    libgdk-pixbuf2.0-0 \
    libgdk-pixbuf2.0-common \
    libgnutls-openssl27 \
    libgnutls30 \
    libgnutlsxx28 \
    libgraphite2-3 \
    libgraphite2-3 \
    libgs9 \
    libharfbuzz-gobject0 \
    libharfbuzz-icu0 \
    libharfbuzz0b \
    liblzf1 \
    libmagickcore-6.q16-3-extra \
    libmcrypt4 \
    libmemcached11 \
    libmp3lame0 \
    libmysqlclient21 \
    libnuma1 \
    libogg0 \
    libonig5 \
    libopencore-amrnb0 \
    libopencore-amrwb0 \
    libopus0 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libpangoft2-1.0-0 \
    libpixman-1-0 \
    librabbitmq4 \
    librsvg2-2 \
    librsvg2-common \
    libsasl2-modules \
    libseccomp2 \
    libsodium23 \
    libspeex1 \
    libthai-data \
    libthai0 \
    libtheora0 \
    libunistring2 \
    libuv1 \
    libvips42 \
    libvorbis0a \
    libvorbisenc2 \
    libvorbisfile3 \
    libvpx6 \
    libwebp6 \
    libwebpdemux2 \
    libwebpmux3 \
    libx264-155 \
    libx265-179 \
    libxcb-render0 \
    libxcb-shm0 \
    libxrender1 \
    libxslt1.1 \
    libzip5 \
    libzstd1 \
    locales \
    lsb-release \
    make \
    netcat-openbsd \
    openssh-client \
    openssh-server \
    patch \
    poppler-utils \
    postgresql-client-15 \
    python-is-python3 \
    python3 \
    rename \
    rsync \
    ruby \
    shared-mime-info \
    socat \
    stunnel \
    syslinux \
    tar \
    telnet \
    tzdata \
    unzip \
    wget \
    xz-utils \
    zip \
    zlib1g \
    zstd \

cp /build/imagemagick-policy.xml /etc/ImageMagick-6/policy.xml

# Temporarily install ca-certificates-java to generate the certificates store used
# by Java apps. Generation occurs in a post-install script which requires a JRE.
# We're using OpenJDK 8 rather than something newer, to work around:
# https://github.com/heroku/base-images/pull/103#issuecomment-389544431
apt-get install -y --no-install-recommends ca-certificates-java openjdk-8-jre-headless
# Using remove rather than purge so that the generated certs are left behind.
apt-get remove -y ca-certificates-java
apt-get purge -y openjdk-8-jre-headless
apt-get autoremove -y --purge
test "$(file -b /etc/ssl/certs/java/cacerts)" = "Java KeyStore"

rm -rf /root/*
rm -rf /tmp/*
rm -rf /var/cache/apt/archives/*.deb
rm -rf /var/lib/apt/lists/*
