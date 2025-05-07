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
  sed --in-place --regexp-extended "s/(Components:.*) ${repository_to_disable}/\1/g" /etc/apt/sources.list.d/ubuntu.sources
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
  bind9-dnsutils # For `dig`, `host` and `nslookup`.
  binutils # Python's `ctypes.util.find_library` requires `ld` to find libraries specified via `LD_LIBRARY_PATH`.
  bzip2
  curl
  file
  fonts-dejavu-core
  fonts-dejavu-mono
  fonts-urw-base35 # ImageMagick's default type.xml config points to these, includes e.g. Courier or Helvetica
  gettext-base # For `envsubst`.
  ghostscript # Used by ImageMagick's PDF functionality
  gir1.2-harfbuzz-0.0 # Used by FFmpeg in heroku-buildpack-activestorage-preview.
  gnupg
  imagemagick
  inetutils-telnet
  iproute2 # For `ip`, used by Heroku Exec.
  iputils-tracepath
  jq # Used by Heroku Exec at run time, and buildpacks at build time.
  less
  libargon2-1 # Used by the PHP runtime.
  libass9 # Used by FFmpeg in heroku-buildpack-activestorage-preview.
  libc-client2007e # Used by the PHP IMAP extension.
  libcares2 # Used by PgBouncer in heroku-buildpack-pgbouncer.
  libdav1d7 # Used by FFmpeg in heroku-buildpack-activestorage-preview.
  libev4
  libevent-2.1-7 # Used by PgBouncer in heroku-buildpack-pgbouncer.
  libevent-core-2.1-7 # Used by the PHP Event extension.
  libevent-extra-2.1-7 # Used by the PHP Event extension.
  libevent-openssl-2.1-7 # Used by the PHP Event extension.
  libevent-pthreads-2.1-7
  libgd3
  libgdk-pixbuf-2.0-0
  libgnutls-openssl27
  libgnutls30 # Used by the Ruby and PHP runtimes.
  libharfbuzz-icu0 # Used by FFmpeg in heroku-buildpack-activestorage-preview.
  liblttng-ust1 # Used by the .NET runtime.
  liblzf1 # Used by the PHP Redis extension.
  libmagickcore-6.q16-7-extra # Used by the PHP Imagick extension (using the `-extra` package for SVG support).
  libmemcached11 # Used by the PHP Memcached extension.
  libmemcachedutil2t64 # Same -dev headers as libmemcached11
  libmp3lame0 # Used by FFmpeg in heroku-buildpack-activestorage-preview.
  libmysqlclient21
  libncurses6 # Used by the Ruby runtime.
  libonig5 # Used by the PHP runtime.
  libopencore-amrnb0 # Used by FFmpeg in heroku-buildpack-activestorage-preview.
  libopencore-amrwb0 # Used by FFmpeg in heroku-buildpack-activestorage-preview.
  libopus0 # Used by FFmpeg in heroku-buildpack-activestorage-preview.
  librabbitmq4 # Used by the PHP AMQP extension.
  librsvg2-common
  libsasl2-modules # Used by the Ruby and PHP runtimes.
  libsodium23 # Used by the PHP runtime.
  libspeex1 # Used by FFmpeg in heroku-buildpack-activestorage-preview.
  libsvtav1enc1d1 # Used by FFmpeg in heroku-buildpack-activestorage-preview.
  libtheora0 # Used by FFmpeg in heroku-buildpack-activestorage-preview.
  libuv1
  libvips42 # Used by the ruby-vips gem / Rails Active Storage Previews.
  libvorbisenc2 # Used by FFmpeg in heroku-buildpack-activestorage-preview.
  libvorbisfile3 # Used by FFmpeg in heroku-buildpack-activestorage-preview.
  libvpx9 # Used by FFmpeg in heroku-buildpack-activestorage-preview.
  libwebpdecoder3 # Same -dev headers as the other libwebp* packages that get pulled in already
  libwmf-0.2-7 # Because libwmf-dev is in the build image
  libx264-164 # Used by FFmpeg in heroku-buildpack-activestorage-preview.
  libx265-199 # Used by FFmpeg in heroku-buildpack-activestorage-preview.
  libxslt1.1 # Used by the PHP runtime.
  libyaml-0-2 # Used by the Ruby runtime.
  libzip4 # Used by the PHP runtime.
  locales
  lsb-release
  nano # More usable than ed but still much smaller than vim.
  netcat-openbsd
  openssh-client # Used by Heroku Exec.
  openssh-server # Used by Heroku Exec.
  patch
  poppler-utils # For Rails Active Storage Previews PDF support.
  postgresql-client-17 # We need `psql` (and not just libpq) for Shield DB workflows (where connections are only possible from the dyno).
  rsync
  socat
  tar
  tzdata
  unzip
  wget
  xz-utils
  zip
  zstd
)

apt-get install -y --no-install-recommends "${packages[@]}"

# Generate locale data for "en_US.UTF-8" too, since the upstream Ubuntu image
# only ships with the "C", "C.utf8" and "POSIX" locales:
# https://github.com/docker-library/docs/blob/master/ubuntu/README.md#locales
locale-gen en_US.UTF-8

# Install AWS RDS global CA bundle (https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/UsingWithRDS.SSL.html#UsingWithRDS.SSL.CertificatesAllRegions)
mkdir -p /usr/local/share/ca-certificates/rds-ca-certs
awk '
  split_after == 1 {n++;split_after=0}
  /-----END CERTIFICATE-----/ {split_after=1}
  {print > "/usr/local/share/ca-certificates/rds-ca-certs/rds-ca" n ".crt"}' < /build/rds-global-bundle.pem
update-ca-certificates

# Install ca-certificates-java so that the JVM buildpacks can configure Java apps to use the Java certs
# store in the base image instead of the one that ships in each JRE release, allowing certs to be updated
# via base image updates. Generation of the `cacerts` file occurs in a post-install script which only runs
# if a JRE is installed, however, we don't want a JRE in the final image so remove it afterwards.
apt-get install -y --no-install-recommends ca-certificates-java default-jre-headless
apt-get remove -y --purge --auto-remove default-jre-headless
# Check that the certs store (a) still exists after the removal of default-jre-headless, (b) uses the JKS
# format not PKCS12, since in the past there was an upstream regression for this:
# https://github.com/heroku/base-images/pull/103#issuecomment-389544431
# https://bugs.launchpad.net/ubuntu/+source/ca-certificates-java/+bug/1771363
test "$(file --brief /etc/ssl/certs/java/cacerts)" = "Java KeyStore"

# Remove /usr/lib/ssl/cert.pem symlink.
# We remove this so that libraries calling X509_STORE_set_default_paths
# don't have to load the unhashed bundle.
if [ -f "/usr/lib/ssl/cert.pem" ]; then
  rm "/usr/lib/ssl/cert.pem"
fi

# Ubuntu 24.04 ships with a default user and group named 'ubuntu' (with user+group ID of 1000)
# that we have to remove before creating our own (`userdel` will remove the group too).
userdel ubuntu --remove

groupadd heroku --gid 1000
useradd heroku --uid 1000 --gid 1000 --shell /bin/bash --create-home

rm -rf /root/*
rm -rf /tmp/*
rm -rf /var/cache/apt/archives/*.deb
rm -rf /var/lib/apt/lists/*
