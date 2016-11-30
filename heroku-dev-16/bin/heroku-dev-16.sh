#!/bin/bash

exec 2>&1
set -e
set -x

apt-get update
apt-get install -y --force-yes \
    autoconf \
    bison \
    build-essential \
    libbind-dev \
    libbsd-dev \
    libbz2-dev \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libevent-dev \
    libev-dev \
    libffi-dev \
    libgcrypt20-dev \
    libglib2.0-dev \
    libgnutls-dev \
    libicu-dev \
    libidn11-dev \
    libjpeg-dev \
    libkrb5-dev \
    libldap2-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libmemcached-dev \
    libmysqlclient-dev \
    libncurses5-dev \
    libpam0g-dev \
    libpq-dev \
    libreadline-dev \
    libssl-dev \
    libuv1-dev \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev \
    postgresql-server-dev-9.5 \
    python-dev \
    ruby-dev \
    zlib1g-dev \

cd /
rm -rf /var/cache/apt/archives/*.deb
rm -rf /root/*
rm -rf /tmp/*

# remove SUID and SGID flags from all binaries
function pruned_find() {
  find / -type d \( -name dev -o -name proc \) -prune -o $@ -print
}

pruned_find -perm /u+s | xargs -r chmod u-s
pruned_find -perm /g+s | xargs -r chmod g-s

# remove non-root ownership of files
#chown root:root /var/lib/libuuid; true

# display build summary
set +x
echo -e "\nRemaining suspicious security bits:"
(
  pruned_find ! -user root
  pruned_find -perm /u+s
  pruned_find -perm /g+s
  pruned_find -perm /+t
) | sed -u "s/^/  /"

echo -e "\nSuccess!"
exit 0
