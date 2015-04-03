FROM ubuntu-debootstrap:14.04
COPY ./bin/cedar-14.sh /tmp/build.sh
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive /tmp/build.sh \
  && rm -rf /var/lib/apt/lists/*
