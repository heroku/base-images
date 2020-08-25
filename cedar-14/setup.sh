#!/usr/bin/env bash

set -euo pipefail

# Redirect stderr to stdout since tracing/apt-get/dpkg spam it for things that aren't errors.
exec 2>&1
set -x

export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C

# Based on ubuntu-debootstrap:14.04's shorter sources list (compared to ubuntu:14.04)
cat > /etc/apt/sources.list <<EOF
deb http://archive.ubuntu.com/ubuntu/ trusty main universe
deb http://archive.ubuntu.com/ubuntu/ trusty-security main universe
deb http://archive.ubuntu.com/ubuntu/ trusty-updates main universe

deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main
EOF

apt-key add - <<'PGDG_ACCC4CF8'
-----BEGIN PGP PUBLIC KEY BLOCK-----

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
=DA1T
-----END PGP PUBLIC KEY BLOCK-----
PGDG_ACCC4CF8


# Confgure ESM

# ESM uses HTTPS sources, which Ubuntu 14.04 doesn't support out of the box.
apt-get update
apt-get install -y --force-yes apt apt-transport-https apt-utils libapt-inst1.5 libapt-pkg4.12

# heroku-buildpack-apt uses /etc/apt/sources.list as the basis for its own APT sources
# list, so the ESM sources must be stored separately to prevent authentication errors
# from the buildpack trying to connect to esm.ubuntu.com without credentials.
cat > /etc/apt/sources.list.d/ubuntu-esm-trusty.list <<EOF
deb https://esm.ubuntu.com/ubuntu trusty-security main
deb https://esm.ubuntu.com/ubuntu trusty-updates main
EOF

APT_AUTH_CONFIG_DIR='/etc/apt/auth.conf.d'
mkdir -p "${APT_AUTH_CONFIG_DIR}"
cat > "${APT_AUTH_CONFIG_DIR}/90ubuntu-advantage" <<EOF
machine esm.ubuntu.com login ${ESM_USERNAME} password ${ESM_PASSWORD}
EOF

apt-key add - <<'ESM_EF1B9BA3'
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

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
=j6go
-----END PGP PUBLIC KEY BLOCK-----
ESM_EF1B9BA3

apt-get update
apt-get upgrade -y --force-yes
apt-get install -y --force-yes \
    autoconf \
    acl \
    apt-transport-https \
    bind9-host \
    bison \
    build-essential \
    coreutils \
    curl \
    daemontools \
    dbus \
    dnsutils \
    ed \
    fuse \
    git \
    groff-base \
    gvfs \
    imagemagick \
    iputils-tracepath \
    jq \
    language-pack-en \
    libbz2-dev \
    libc-client2007e \
    libcurl4-openssl-dev \
    libev-dev \
    libevent-dev \
    libgconf-2-4 \
    libglib2.0-dev \
    libgnome2-0 \
    libgtk-3-0 \
    libicu52 \
    libjpeg-dev \
    libmagickwand-dev \
    libmcrypt4 \
    libmemcached-dev \
    libmysqlclient-dev \
    libncurses5-dev \
    libpq-dev \
    libpq5 \
    librdkafka-dev \
    libreadline6-dev \
    libssl-dev \
    libuv-dev \
    libxml2-dev \
    libxslt-dev \
    locales \
    mercurial \
    netcat-openbsd \
    ntfs-3g \
    openjdk-7-jdk \
    openjdk-7-jre-headless \
    openssh-client \
    openssh-server \
    postgresql-client-11 \
    postgresql-server-dev-11 \
    psmisc \
    python \
    python-dev \
    realpath \
    ruby \
    ruby-dev \
    socat \
    stunnel \
    syslinux \
    tar \
    telnet \
    tzdata \
    xkb-data \
    zip \
    zlib1g-dev \
    #

# locales
apt-cache search language-pack \
    | cut -d ' ' -f 1 \
    | grep -v '^language\-pack\-\(gnome\|kde\)\-' \
    | grep -v '\-base$' \
    | xargs apt-get install -y --force-yes --no-install-recommends

cat > /etc/ImageMagick/policy.xml <<'IMAGEMAGICK_POLICY'
<policymap>
  <policy domain="coder" rights="none" pattern="EPHEMERAL" />
  <policy domain="coder" rights="none" pattern="URL" />
  <policy domain="coder" rights="none" pattern="HTTPS" />
  <policy domain="coder" rights="none" pattern="MVG" />
  <policy domain="coder" rights="none" pattern="MSL" />
  <policy domain="coder" rights="none" pattern="TEXT" />
  <policy domain="coder" rights="none" pattern="SHOW" />
  <policy domain="coder" rights="none" pattern="WIN" />
  <policy domain="coder" rights="none" pattern="PLT" />
  <policy domain="path" rights="none" pattern="@*" />
</policymap>
IMAGEMAGICK_POLICY

rm -r "${APT_AUTH_CONFIG_DIR}"
rm -rf /root/*
rm -rf /tmp/*
rm -rf /var/cache/apt/archives/*.deb
rm -rf /var/lib/apt/lists/*

# Sanity check that we cleaned up the ESM credentials correctly.
# xtrace is disabled in the subshell to prevent the password from ending up in the logs.
if (set +x && grep -qr "${ESM_PASSWORD}" /etc /var); then
  echo 'Error: ESM credentials not cleaned up correctly!'
  exit 1
fi

# remove SUID and SGID flags from all binaries
function pruned_find() {
  find / -type d \( -name dev -o -name proc \) -prune -o "$@" -print
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
) | sed "s/^/  /"

echo -e "\nInstalled versions:"
(
  git --version
  ruby -v
  gem -v
  python -V
) 2>&1 | sed "s/^/  /"

echo -e "\nSuccess!"
