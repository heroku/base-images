FROM ubuntu-debootstrap:14.04
ARG ESM_USERNAME
ARG ESM_PASSWORD
COPY setup.sh /tmp/setup.sh
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive /tmp/setup.sh \
  && rm -rf /var/lib/apt/lists/*
