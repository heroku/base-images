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
apt-get install -y --force-yes ed bison
apt-get install -y --force-yes openssh-client openssh-server
apt-get install -y --force-yes imagemagick libmagick9-dev
apt-get install -y --force-yes ia32-libs

cd /tmp
curl --retry 3 --max-time 60 --write-out %{http_code} --silent -o squashfs-tools_3.3-1ubuntu2_amd64.deb http://launchpadlibrarian.net/11397899/squashfs-tools_3.3-1ubuntu2_amd64.deb
dpkg -i squashfs-tools_3.3-1ubuntu2_amd64.deb

cd /tmp
curl -L -o git-1.7.0.tar.gz https://github.com/git/git/tarball/v1.7.0
mkdir -p git-1.7.0
cd git-1.7.0
tar --strip-components 1 -xzvf ../git-1.7.0.tar.gz
NO_EXPAT=yes NO_SVN_TESTS=yes NO_IPV6=yes NO_TCLTK=yes make prefix=/usr
NO_EXPAT=yes NO_SVN_TESTS=yes NO_IPV6=yes NO_TCLTK=yes make install prefix=/usr

apt-get install -y --force-yes openjdk-6-jdk openjdk-6-jre-headless

cd /tmp
curl -O "http://www.python.org/ftp/python/2.7.2/Python-2.7.2.tgz"
tar xfz Python-2.7.2.tgz
cd Python-2.7.2
./configure
make
make install

cd /tmp
curl -O http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.tar.gz
tar xzf ruby-1.9.2-p290.tar.gz
cd ruby-1.9.2-p290
./configure --prefix=/usr/local
make
make install

cd /tmp
curl -O "http://www.erlang.org/download/otp_src_R14B04.tar.gz"
tar xfz otp_src_R14B04.tar.gz
cd otp_src_R14B04
./configure
make
make install

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
