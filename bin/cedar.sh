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
apt-get install -y --force-yes libxslt-dev libxml2-dev libglib2.0-dev \
    libbz2-dev libreadline5-dev zlib1g-dev libevent-dev libssl-dev libpq-dev \
    libncurses5-dev libcurl4-openssl-dev libjpeg-dev libmysqlclient-dev
apt-get install -y --force-yes daemontools
apt-get install -y --force-yes curl netcat telnet
apt-get install -y --force-yes ed bison
apt-get install -y --force-yes openssh-client openssh-server
apt-get install -y --force-yes imagemagick libmagick9-dev
apt-get install -y --force-yes ia32-libs
apt-get install -y --force-yes openjdk-6-jdk openjdk-6-jre-headless

# pull in a newer libpq
echo "deb http://apt.postgresql.org/pub/repos/apt/ lucid-pgdg main" >> /etc/apt/sources.list

cat > /etc/apt/preferences <<EOF
Package: *
Pin: release a=lucid-pgdg
Pin-Priority: -10
EOF

curl -o /tmp/postgres.asc http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc
if [ "$(sha256sum /tmp/postgres.asc)" = \
    "fbdb6c565cd95957b645197686587f7735149383a3d5e1291b6830e6730e672f" ]; then
    apt-key add /tmp/postgres.asc
fi

apt-get update
apt-get install -y --force-yes -t lucid-pgdg libpq5 libpq-dev

# need an older squashfs-tools
cd /tmp
curl --retry 3 --max-time 60 --write-out %{http_code} --silent -o squashfs-tools_3.3-1ubuntu2_amd64.deb http://launchpadlibrarian.net/11397899/squashfs-tools_3.3-1ubuntu2_amd64.deb
dpkg -i squashfs-tools_3.3-1ubuntu2_amd64.deb

# git changes important semantics in sub-bugfix version bumps unfortunately:
# http://git.661346.n2.nabble.com/Git-sideband-hook-output-td5155362.html

cd /tmp
curl -L -o git-1.7.0.tar.gz https://github.com/git/git/tarball/v1.7.0
mkdir -p git-1.7.0
cd git-1.7.0
tar --strip-components 1 -xzvf ../git-1.7.0.tar.gz
NO_EXPAT=yes NO_SVN_TESTS=yes NO_IPV6=yes NO_TCLTK=yes make prefix=/usr
NO_EXPAT=yes NO_SVN_TESTS=yes NO_IPV6=yes NO_TCLTK=yes make install prefix=/usr

function fetch_verify_tarball() {
    cd /tmp
    local tarball=$(basename $1)
    curl -o $tarball $1
    if [ "$(sha256sum $tarball)" != "$2" ]; then
        echo "Checksum mismatch for $1!"
        # exit 1
    fi
    tar xzf $tarball
}

fetch_verify_tarball "http://www.python.org/ftp/python/2.7.2/Python-2.7.2.tgz" \
    "1d54b7096c17902c3f40ffce7e5b84e0072d0144024184fff184a84d563abbb3  Python-2.7.2.tgz"
cd Python-2.7.2 && ./configure && make && make install

fetch_verify_tarball "http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.tar.gz" \
    "1cc817575c4944d3d78959024320ed1d5b7c2b4931a855772dacad7c3f6ebd7e  ruby-1.9.2-p290.tar.gz"
cd ruby-1.9.2-p290 && ./configure --prefix=/usr/local && make && make install

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
