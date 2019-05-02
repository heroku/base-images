#!/bin/bash

exec 2>&1
set -e
set -x

cat > /etc/apt/sources.list <<EOF
deb http://archive.ubuntu.com/ubuntu/ trusty main universe
deb http://archive.ubuntu.com/ubuntu/ trusty-security main universe
deb http://archive.ubuntu.com/ubuntu/ trusty-updates main universe

deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main
EOF

apt-key add - <<'PGDG_ACCC4CF8'
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

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
IIP9up4xwgje9LB7fMxsSkCDTHOk
=s3DI
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
    language-pack-en \
    libbz2-dev \
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

cd /
rm -r "${APT_AUTH_CONFIG_DIR}"
rm -rf /var/cache/apt/archives/*.deb
rm -rf /root/*
rm -rf /tmp/*

# Sanity check that we cleaned up the ESM credentials correctly.
# xtrace is disabled in the subshell to prevent the password from ending up in the logs.
if (set +x && grep -qr "${ESM_PASSWORD}" /etc /var); then
  echo 'Error: ESM credentials not cleaned up correctly!'
  exit 1
fi

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
) | sed "s/^/  /"

echo -e "\nInstalled versions:"
(
  git --version
  ruby -v
  gem -v
  python -V
) 2>&1 | sed "s/^/  /"

echo -e "\nSuccess!"
exit 0
