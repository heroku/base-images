#!/bin/bash

exec 2>&1
set -e
set -x

cat > /etc/apt/sources.list <<EOF
deb http://archive.ubuntu.com/ubuntu lucid main
deb http://archive.ubuntu.com/ubuntu lucid-security main
deb http://archive.ubuntu.com/ubuntu lucid-updates main
deb http://archive.ubuntu.com/ubuntu lucid universe
EOF

apt-get update
apt-get install -y --force-yes language-pack-en
apt-get install -y --force-yes coreutils tar build-essential autoconf
apt-get install -y --force-yes libxslt-dev libxml2-dev libglib2.0-dev libbz2-dev libreadline5-dev zlib1g-dev libevent-dev libssl-dev libpq-dev libncurses5-dev libcurl4-openssl-dev libjpeg-dev libmysqlclient-dev
apt-get install -y --force-yes daemontools
apt-get install -y --force-yes curl netcat telnet
apt-get install -y --force-yes git-core
apt-get install -y --force-yes ed bison
apt-get install -y --force-yes openssh-client openssh-server
apt-get install -y --force-yes imagemagick libmagick9-dev
apt-get install -y --force-yes ia32-libs
apt-get install -y --force-yes openjdk-6-jdk openjdk-6-jre-headless

# need an older squashfs-tools
cd /tmp
curl --retry 3 --max-time 60 --write-out %{http_code} --silent -o squashfs-tools_3.3-1ubuntu2_amd64.deb http://launchpadlibrarian.net/11397899/squashfs-tools_3.3-1ubuntu2_amd64.deb
dpkg -i squashfs-tools_3.3-1ubuntu2_amd64.deb

function fetch_verify_tarball() {
    cd /tmp
    local tarball=$(basename $1)
    curl -o $tarball $1
    if [ "$(md5sum $tarball)" != "$2" ]; then
        echo "Checksum mismatch for $1!"
        # exit 1
    fi
    tar xzf $tarball
}

fetch_verify_tarball "http://www.python.org/ftp/python/2.7.2/Python-2.7.2.tgz" \
    "0ddfe265f1b3d0a8c2459f5bf66894c7  Python-2.7.2.tgz"
cd Python-2.7.2 && ./configure && make && make install

fetch_verify_tarball "http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.tar.gz" \
    "604da71839a6ae02b5b5b5e1b792d5eb  ruby-1.9.2-p290.tar.gz"
cd ruby-1.9.2-p290 && ./configure --prefix=/usr/local && make && make install

fetch_verify_tarball "http://www.erlang.org/download/otp_src_R14B04.tar.gz" \
    "4b469729f103f52702bfb1fb24529dc0  otp_src_R14B04.tar.gz"
cd otp_src_R14B04 && ./configure && make && make install

# remove non-root owned artifacts of erlang
rm -rf /usr/local/lib/erlang/lib/sasl-2.1.10/examples/
rm -rf /usr/local/lib/erlang/lib/ssl-4.1.6/examples/
rm -rf /usr/local/lib/erlang/lib/kernel-2.14.5/examples/

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
