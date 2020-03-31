FROM heroku/heroku:16
COPY setup.sh /tmp/setup.sh
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive /tmp/setup.sh \
  && rm -rf /var/lib/apt/lists/*
