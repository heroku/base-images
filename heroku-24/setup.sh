#!/usr/bin/env bash

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

# Disable APT repositories that contain packages with potentially problematic licenses.
# We edit the existing file rather than using our own static file contents, since the repository
# URIs vary across architectures, so we would otherwise have to hardcode multiple file variants.
# There are multiple repository configuration lines in the file, all of form:
# `Components: main universe restricted multiverse`
# See: https://manpages.ubuntu.com/manpages/noble/en/man5/sources.list.5.html
for repository_to_disable in multiverse restricted; do
  # sed doesn't support lookbehind so we instead have to match against the line prefix too
  # and then preserve it using `\1` in the replacement.
  sed --in-place --regexp-extended "s/(Components:.*) ?${repository_to_disable}/\1/g" /etc/apt/sources.list.d/ubuntu.sources
done

apt-get update --error-on=any

# We have to install certificates first, so that APT can use HTTPS for apt.postgresql.org.
apt-get install -y --no-install-recommends ca-certificates

# In order to support all features offered by Heroku Postgres, we need newer postgresql-client
# than is available in the Ubuntu repository, so use the upstream APT repository instead:
# https://wiki.postgresql.org/wiki/Apt
cat >/etc/apt/sources.list.d/pgdg.sources <<'EOF'
Types: deb
URIs: https://apt.postgresql.org/pub/repos/apt
Suites: noble-pgdg
Components: main
Signed-By: /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc
EOF
mkdir -p /usr/share/postgresql-common/pgdg/
cp /build/postgresql-ACCC4CF8.asc /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc

apt-get update --error-on=any
apt-get upgrade -y --no-install-recommends

packages=(
  apt-utils
  # For dig, host and nslookup.
  bind9-dnsutils
  bzip2
  coreutils
  curl
  file
  fontconfig
  geoip-database
  gettext-base
  gir1.2-harfbuzz-0.0
  gnupg
  imagemagick
  inetutils-telnet
  iproute2
  iputils-tracepath
  less
  libaom3
  libargon2-1
  libass9
  libc-client2007e
  libcairo2
  libcurl4
  libdatrie1
  libdav1d7
  libev4
  libevent-2.1-7
  libevent-core-2.1-7
  libevent-extra-2.1-7
  libevent-openssl-2.1-7
  libevent-pthreads-2.1-7
  libexif12
  libfreetype6
  libfribidi0
  libgd3
  libgdk-pixbuf2.0-0
  libgdk-pixbuf2.0-common
  libgnutls-openssl27
  libgnutls30
  libgraphite2-3
  libgraphite2-3
  libharfbuzz-gobject0
  libharfbuzz-icu0
  libharfbuzz0b
  libheif1
  liblzf1
  libmagickcore-6.q16-7-extra
  libmcrypt4
  libmemcached11
  libmp3lame0
  libmysqlclient21
  libnuma1
  libogg0
  libonig5
  libopencore-amrnb0
  libopencore-amrwb0
  libopus0
  libpango-1.0-0
  libpangocairo-1.0-0
  libpangoft2-1.0-0
  libpixman-1-0
  librabbitmq4
  librsvg2-2
  librsvg2-common
  libsasl2-modules
  libseccomp2
  libsodium23
  libspeex1
  libsvtav1enc1d1
  libthai-data
  libthai0
  libtheora0
  libunistring5
  libuv1
  libvips42
  libvorbis0a
  libvorbisenc2
  libvorbisfile3
  libvpx9
  libwebp7
  libwebpdemux2
  libwebpmux3
  libx264-164
  libx265-199
  libxcb-render0
  libxcb-shm0
  libxrender1
  libxslt1.1
  libyaml-0-2
  libzip4
  libzstd1
  locales
  lsb-release
  # Nano is more usable than ed but still much smaller than vim.
  nano
  netcat-openbsd
  openssh-client
  openssh-server
  patch
  poppler-utils
  postgresql-client-16
  rename
  rsync
  shared-mime-info
  socat
  tar
  tzdata
  unzip
  wget
  xz-utils
  zip
  zlib1g
  zstd
)

apt-get install -y --no-install-recommends "${packages[@]}"

# Generate locale data for "en_US", which is not available by default. Ubuntu
# ships only with "C" and "POSIX" locales.
locale-gen en_US.UTF-8

# Temporarily install ca-certificates-java to generate the certificates store used
# by Java apps. Generation occurs in a post-install script which requires a JRE.
# We're using OpenJDK 8 rather than something newer, to work around:
# https://github.com/heroku/stack-images/pull/103#issuecomment-389544431
apt-get install -y --no-install-recommends ca-certificates-java openjdk-8-jre-headless
# Using remove rather than purge so that the generated certs are left behind.
apt-get remove -y ca-certificates-java
apt-get purge -y openjdk-8-jre-headless
apt-get autoremove -y --purge
test "$(file -b /etc/ssl/certs/java/cacerts)" = "Java KeyStore"

# Ubuntu 24.04 ships with a default user and group named 'ubuntu' (with user+group ID of 1000)
# that we have to remove before creating our own (`userdel` will remove the group too).
userdel ubuntu --remove

groupadd heroku --gid 1000
useradd heroku --uid 1000 --gid 1000 --shell /bin/bash --create-home

rm -rf /root/*
rm -rf /tmp/*
rm -rf /var/cache/apt/archives/*.deb
rm -rf /var/lib/apt/lists/*
