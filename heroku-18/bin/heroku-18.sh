#!/bin/bash

exec 2>&1
set -e
set -x

cat >/etc/apt/sources.list <<EOF
deb http://archive.ubuntu.com/ubuntu/ bionic main universe
deb http://archive.ubuntu.com/ubuntu/ bionic-security main universe
deb http://archive.ubuntu.com/ubuntu/ bionic-updates main universe
EOF

apt-get update
apt-get install -y --no-install-recommends gnupg

cat >>/etc/apt/sources.list <<EOF
deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main
EOF

apt-key add - <<'PGDG_ACCC4CF8'
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

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
IIP9up4xwgje9LB7fMxsSkCDTHOk
=s3DI
-----END PGP PUBLIC KEY BLOCK-----
PGDG_ACCC4CF8

apt-get update
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
    geoip-database \
    ghostscript \
    git \
    gsfonts \
    imagemagick \
    iproute2 \
    iputils-tracepath \
    language-pack-en \
    less \
    libcurl4 \
    libev4 \
    libevent-2.1-6 \
    libevent-core-2.1-6 \
    libevent-extra-2.1-6 \
    libevent-openssl-2.1-6 \
    libevent-pthreads-2.1-6 \
    libexif12 \
    libgd3 \
    libgnutls-openssl27 \
    libgnutlsxx28 \
    libgs9 \
    libmcrypt4 \
    libmemcached11 \
    libmysqlclient20 \
    librabbitmq4 \
    libseccomp2 \
    libsodium23 \
    libuv1 \
    libxslt1.1 \
    locales \
    lsb-release \
    make \
    netcat-openbsd \
    openssh-client \
    openssh-server \
    patch \
    postgresql-client-10 \
    python \
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

# install the JDK for certificates, then remove it
apt-get install -y --no-install-recommends ca-certificates-java openjdk-8-jre-headless
apt-get remove -y ca-certificates-java
apt-get -y --purge autoremove
apt-get purge -y openjdk-8-jre-headless
test "$(file -b /etc/ssl/certs/java/cacerts)" = "Java KeyStore"

cd /
rm -rf /root/*
rm -rf /tmp/*
rm -rf /var/cache/apt/archives/*.deb
