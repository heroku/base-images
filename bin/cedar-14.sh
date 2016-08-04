#!/bin/bash

exec 2>&1
set -e
set -x

cat > /etc/apt/sources.list <<EOF
deb http://archive.ubuntu.com/ubuntu trusty main
deb http://archive.ubuntu.com/ubuntu trusty-security main
deb http://archive.ubuntu.com/ubuntu trusty-updates main
deb http://archive.ubuntu.com/ubuntu trusty universe

deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main
deb http://repo.mysql.com/apt/ubuntu/ trusty mysql-5.7
EOF

apt-key add - <<'PGDG_ACCC4CF8'
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

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
IIP9up4xwgje9LB7fMxsSkCDTHOk
=s3DI
-----END PGP PUBLIC KEY BLOCK-----
PGDG_ACCC4CF8

apt-key add - <<'MYSQL_5072E1F5'
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.9 (SunOS)

mQGiBD4+owwRBAC14GIfUfCyEDSIePvEW3SAFUdJBtoQHH/nJKZyQT7h9bPlUWC3
RODjQReyCITRrdwyrKUGku2FmeVGwn2u2WmDMNABLnpprWPkBdCk96+OmSLN9brZ
fw2vOUgCmYv2hW0hyDHuvYlQA/BThQoADgj8AW6/0Lo7V1W9/8VuHP0gQwCgvzV3
BqOxRznNCRCRxAuAuVztHRcEAJooQK1+iSiunZMYD1WufeXfshc57S/+yeJkegNW
hxwR9pRWVArNYJdDRT+rf2RUe3vpquKNQU/hnEIUHJRQqYHo8gTxvxXNQc7fJYLV
K2HtkrPbP72vwsEKMYhhr0eKCbtLGfls9krjJ6sBgACyP/Vb7hiPwxh6rDZ7ITnE
kYpXBACmWpP8NJTkamEnPCia2ZoOHODANwpUkP43I7jsDmgtobZX9qnrAXw+uNDI
QJEXM6FSbi0LLtZciNlYsafwAPEOMDKpMqAK6IyisNtPvaLd8lH0bPAnWqcyefep
rv0sxxqUEMcM3o7wwgfN83POkDasDbs3pjwPhxvhz6//62zQJ7Q2TXlTUUwgUmVs
ZWFzZSBFbmdpbmVlcmluZyA8bXlzcWwtYnVpbGRAb3NzLm9yYWNsZS5jb20+iGkE
ExECACkCGyMGCwkIBwMCBBUCCAMEFgIDAQIeAQIXgAIZAQUCUwHUZgUJGmbLywAK
CRCMcY07UHLh9V+DAKCjS1gGwgVI/eut+5L+l2v3ybl+ZgCcD7ZoA341HtoroV3U
6xRD09fUgeq0O015U1FMIFBhY2thZ2Ugc2lnbmluZyBrZXkgKHd3dy5teXNxbC5j
b20pIDxidWlsZEBteXNxbC5jb20+iG8EMBECAC8FAk53Pa0oHSBidWlsZEBteXNx
bC5jb20gd2lsbCBzdG9wIHdvcmtpbmcgc29vbgAKCRCMcY07UHLh9bU9AJ9xDK0o
xJFL9vTl9OSZC4lX0K9AzwCcCrS9cnJyz79eaRjL0s2r/CcljdyIZQQTEQIAHQUC
R6yUtAUJDTBYqAULBwoDBAMVAwIDFgIBAheAABIJEIxxjTtQcuH1B2VHUEcAAQGu
kgCffz4GUEjzXkOi71VcwgCxASTgbe0An34LPr1j9fCbrXWXO14msIADfb5piEwE
ExECAAwFAj4+o9EFgwlmALsACgkQSVDhKrJykfIk4QCfWbEeKN+3TRspe+5xKj+k
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
AcOphrnJ
=443I
-----END PGP PUBLIC KEY BLOCK-----
MYSQL_5072E1F5

apt-get update
apt-get upgrade -y --force-yes

# We install libmysqlclient-dev 5.7.x (which will include libmysqlclient20
# and mysql-common) from repo.mysql.com to fix CVE-2015-3152. For backwards
# compatibility with already compiled apps, we must still install the older
# mysql 5.5.x based libmysqlclient18 from archive.ubuntu.com. See:
# https://github.com/heroku/stack-images/pull/38
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
    git \
    imagemagick \
    iputils-tracepath \
    language-pack-en \
    libbz2-dev \
    libcurl4-openssl-dev \
    libev-dev \
    libevent-dev \
    libglib2.0-dev \
    libjpeg-dev \
    libmagickwand-dev \
    libmysqlclient-dev \
    libmysqlclient18 \
    libncurses5-dev \
    libpq-dev \
    libpq5 \
    librdkafka-dev \
    libreadline6-dev \
    libssl-dev \
    libuv-dev \
    libxml2-dev \
    libxslt-dev \
    netcat-openbsd \
    openjdk-7-jdk \
    openjdk-7-jre-headless \
    openssh-client \
    openssh-server \
    postgresql-client-9.6 \
    postgresql-server-dev-9.6 \
    python \
    python-dev \
    ruby \
    ruby-dev \
    socat \
    stunnel \
    syslinux \
    tar \
    telnet \
    zip \
    zlib1g-dev \
    #

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
  ruby -v
  gem -v
  python -V
) 2>&1 | sed -u "s/^/  /"

echo -e "\nSuccess!"
exit 0
