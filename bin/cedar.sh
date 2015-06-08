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
apt-get upgrade -y --force-yes
apt-get install -y --force-yes \
    autoconf \
    bind9-host \
    bison \
    build-essential \
    coreutils \
    curl \
    daemontools \
    dnsutils \
    ed \
    ia32-libs \
    imagemagick \
    iputils-tracepath \
    language-pack-en \
    libbz2-dev \
    libcurl4-openssl-dev \
    libevent-dev \
    libglib2.0-dev \
    libjpeg-dev \
    libmagick9-dev \
    libmysqlclient-dev \
    libncurses5-dev \
    libpq-dev \
    libreadline5-dev \
    libssl-dev \
    libxml2-dev \
    libxslt-dev \
    netcat-openbsd \
    openjdk-6-jdk \
    openjdk-6-jre-headless \
    openssh-client \
    openssh-server \
    socat \
    syslinux \
    tar \
    telnet \
    timeout \
    zlib1g-dev \
    #

# locales
apt-get install -y --force-yes --no-install-recommends language-pack-aa \
    language-pack-af language-pack-am language-pack-an language-pack-ar \
    language-pack-as language-pack-ast language-pack-az language-pack-be \
    language-pack-ber language-pack-bg language-pack-bn language-pack-bo \
    language-pack-br language-pack-bs language-pack-ca language-pack-crh \
    language-pack-cs language-pack-csb language-pack-cy language-pack-da \
    language-pack-de language-pack-dv language-pack-dz language-pack-el \
    language-pack-en language-pack-eo language-pack-es language-pack-et \
    language-pack-eu language-pack-fa language-pack-fi language-pack-fil \
    language-pack-fo language-pack-fr language-pack-fur language-pack-fy \
    language-pack-ga language-pack-gd language-pack-gl language-pack-gu \
    language-pack-ha language-pack-he language-pack-hi language-pack-hne \
    language-pack-hr language-pack-hsb language-pack-ht language-pack-hu \
    language-pack-hy language-pack-ia language-pack-id language-pack-ig \
    language-pack-is language-pack-it language-pack-iu language-pack-ja \
    language-pack-ka language-pack-kk language-pack-km language-pack-kn \
    language-pack-ko language-pack-ks language-pack-ku language-pack-kw \
    language-pack-ky language-pack-la language-pack-lg language-pack-li \
    language-pack-lo language-pack-lt language-pack-lv language-pack-mai \
    language-pack-mg language-pack-mi language-pack-mk language-pack-ml \
    language-pack-mn language-pack-mr language-pack-ms language-pack-mt \
    language-pack-nan language-pack-nb language-pack-nds language-pack-ne \
    language-pack-nl language-pack-nn language-pack-nr language-pack-nso \
    language-pack-oc language-pack-om language-pack-or language-pack-pa \
    language-pack-pap language-pack-pl language-pack-pt language-pack-ro \
    language-pack-ru language-pack-rw language-pack-sa language-pack-sc \
    language-pack-sd language-pack-se language-pack-shs language-pack-si \
    language-pack-sk language-pack-sl language-pack-so language-pack-sq \
    language-pack-sr language-pack-ss language-pack-st language-pack-sv \
    language-pack-ta language-pack-te language-pack-tg language-pack-th \
    language-pack-ti language-pack-tk language-pack-tl language-pack-tlh \
    language-pack-tn language-pack-tr language-pack-ts language-pack-tt \
    language-pack-ug language-pack-uk language-pack-ur language-pack-uz \
    language-pack-ve language-pack-vi language-pack-wa language-pack-wo \
    language-pack-xh language-pack-yi language-pack-yo language-pack-zh \
    language-pack-zh-hans language-pack-zh-hant language-pack-zu

# pull in a newer libpq
echo "deb http://apt.postgresql.org/pub/repos/apt/ lucid-pgdg 9.2" >> /etc/apt/sources.list

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
    curl --location --output $tarball $1
    if [ "$(sha256sum $tarball)" != "$2" ]; then
        echo "Checksum mismatch for $1!"
        exit 1
    fi
    tar xzf $tarball
}

fetch_verify_tarball "http://www.python.org/ftp/python/2.7.6/Python-2.7.6.tgz" \
    "99c6860b70977befa1590029fae092ddb18db1d69ae67e8b9385b66ed104ba58  Python-2.7.6.tgz"
cd Python-2.7.6 && ./configure && make && make install

fetch_verify_tarball "http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p330.tar.gz" \
    "23ef45fdaecc5d6c7b4e9e2d51b23817fc6aa8225a20f123f7fa98760e8b5ca9  ruby-1.9.2-p330.tar.gz"
cd ruby-1.9.2-p330 && ./configure --prefix=/usr/local && make && make install

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
