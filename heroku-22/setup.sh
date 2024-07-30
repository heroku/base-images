#!/usr/bin/env bash

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

# The default sources list minus backports, restricted and multiverse.
cat >/etc/apt/sources.list <<EOF
deb http://archive.ubuntu.com/ubuntu/ jammy main universe
deb http://archive.ubuntu.com/ubuntu/ jammy-security main universe
deb http://archive.ubuntu.com/ubuntu/ jammy-updates main universe
EOF

apt-get update --error-on=any

# Required by apt-key and does not exist in the base image on newer Ubuntu.
apt-get install -y --no-install-recommends gnupg

# In order to support all features offered by Heroku Postgres, we need newer postgresql-client
# than is available in the Ubuntu repository, so use the upstream APT repository instead:
# https://wiki.postgresql.org/wiki/Apt
cat >>/etc/apt/sources.list <<EOF
deb http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main
EOF
apt-key add /build/postgresql-ACCC4CF8.asc

apt-get update --error-on=any
apt-get upgrade -y

packages=(
  apt-transport-https
  apt-utils
  bind9-host
  bzip2
  coreutils
  curl
  dnsutils
  ed
  file
  fontconfig
  gcc
  geoip-database
  gettext-base
  ghostscript
  gir1.2-harfbuzz-0.0
  git
  gsfonts
  imagemagick
  iproute2
  iputils-tracepath
  jq # Used by Heroku Exec at run time, and buildpacks at build time.
  language-pack-en
  less
  libaom3
  libargon2-1
  libass9
  libc-ares2 # Used by PgBouncer in heroku-buildpack-pgbouncer.
  libc-client2007e
  libc6-dev
  libcairo2
  libcurl4
  libdatrie1
  libdav1d5
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
  libgeoip1
  libgnutls-openssl27
  libgnutls30
  libgnutlsxx28
  libgraphite2-3
  libgraphite2-3
  libgs9
  libharfbuzz-gobject0
  libharfbuzz-icu0
  libharfbuzz0b
  libhashkit2
  libheif1
  liblzf1
  libmagickcore-6.q16-3-extra
  libmcrypt4
  libmemcached11
  libmemcachedutil2
  libmp3lame0
  libmysqlclient21
  libnetpbm10
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
  libsvtav1enc0
  libthai-data
  libthai0
  libtheora0
  libunistring2
  libuv1
  libvips42
  libvorbis0a
  libvorbisenc2
  libvorbisfile3
  libvpx7
  libwebp7
  libwebpdemux2
  libwebpmux3
  libwmf-0.2-7
  libx264-163
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
  make
  nano # More usable than ed but still much smaller than vim.
  netcat-openbsd
  openssh-client
  openssh-server
  patch
  poppler-utils
  postgresql-client-16
  python-is-python3
  python3
  rename
  rsync
  shared-mime-info
  socat
  stunnel
  syslinux
  tar
  telnet
  tzdata
  unzip
  wget
  xz-utils
  zip
  zlib1g
  zstd
)

apt-get install -y --no-install-recommends "${packages[@]}"

cp /build/imagemagick-policy.xml /etc/ImageMagick-6/policy.xml

# Install ca-certificates-java so that the JVM buildpacks can configure Java apps to use the Java certs
# store in the base image instead of the one that ships in each JRE release, allowing certs to be updated
# via base image updates. Generation of the `cacerts` file occurs in a post-install script which requires
# a JRE, however, we don't want a JRE in the final image so remove it afterwards.
apt-get install -y --no-install-recommends ca-certificates-java openjdk-8-jre-headless
# For Ubuntu versions prior to 24.04 the ca-certificates-java package has a direct dependency on a JRE, so
# we can't remove the JRE without also removing ca-certificates-java. However, we can work around this by
# not using `--purge` when removing ca-certificates-java, which leaves behind the generated certs store.
apt-get remove -y ca-certificates-java
apt-get remove -y --purge --auto-remove openjdk-8-jre-headless
# Check that the certs store (a) wasn't purged during removal of ca-certificates-java, (b) uses the JKS
# format not PKCS12, since in the past there was an upstream regression for this:
# https://github.com/heroku/base-images/pull/103#issuecomment-389544431
# https://bugs.launchpad.net/ubuntu/+source/ca-certificates-java/+bug/1771363
test "$(file --brief /etc/ssl/certs/java/cacerts)" = "Java KeyStore"

groupadd heroku --gid 1000
useradd heroku --uid 1000 --gid 1000 --shell /bin/bash --create-home

rm -rf /root/*
rm -rf /tmp/*
rm -rf /var/cache/apt/archives/*.deb
rm -rf /var/lib/apt/lists/*
