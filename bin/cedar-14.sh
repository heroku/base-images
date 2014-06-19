#!/bin/bash

exec 2>&1
set -e
set -x

cat > /etc/apt/sources.list <<EOF
deb http://archive.ubuntu.com/ubuntu trusty main
deb http://archive.ubuntu.com/ubuntu trusty-security main
deb http://archive.ubuntu.com/ubuntu trusty-updates main
deb http://archive.ubuntu.com/ubuntu trusty universe
EOF

apt-get update
apt-get install -y --force-yes language-pack-en
apt-get install -y --force-yes coreutils tar build-essential autoconf
apt-get install -y --force-yes libxslt-dev libxml2-dev libglib2.0-dev \
    libbz2-dev libreadline6-dev zlib1g-dev libevent-dev libssl-dev libpq5 libpq-dev \
    libncurses5-dev libcurl4-openssl-dev libjpeg-dev libmysqlclient-dev
apt-get install -y --force-yes daemontools
apt-get install -y --force-yes curl netcat-openbsd telnet
apt-get install -y --force-yes iputils-tracepath bind9-host dnsutils socat
apt-get install -y --force-yes ed bison
apt-get install -y --force-yes openssh-client openssh-server
apt-get install -y --force-yes imagemagick libmagickwand-dev
apt-get install -y --force-yes openjdk-6-jdk openjdk-6-jre-headless
apt-get install -y --force-yes git
apt-get install -y --force-yes python
apt-get install -y --force-yes ruby

# for the "gethostip" tool
apt-get install -y --force-yes syslinux

# locales
apt-cache search language-pack \
    | cut -d ' ' -f 1 \
    | grep -v '^language\-pack\-\(gnome\|kde\)\-' \
    | grep -v '\-base$' \
    | xargs apt-get install -y --force-yes --no-install-recommends

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
chown root:root /var/lib/libuuid

# display build summary
set +x
echo -e "\nRemaining suspicious security bits:"
(
  pruned_find ! -user root
  pruned_find -perm /u+s
  pruned_find -perm /g+s
  pruned_find -perm /+t
) | sed -u "s/^/  /"

echo -e "\nInstalled versions:"
(
  git --version
  java -version
  ruby -v
  gem -v
  python -V
) | sed -u "s/^/  /"

echo -e "\nSuccess!"
exit 0
